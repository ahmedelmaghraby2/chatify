import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class NotificationPayload {
  final String? conversationId;
  final String? messageId;
  final String? callId;
  final String? kind;
  final String title;
  final String body;
  final bool mention;
  final bool reply;

  const NotificationPayload({
    this.conversationId,
    this.messageId,
    this.callId,
    this.kind,
    required this.title,
    required this.body,
    this.mention = false,
    this.reply = false,
  });

  factory NotificationPayload.fromData(Map<String, dynamic> data) {
    return NotificationPayload(
      conversationId: _stringOrNull(data['conversationId']),
      messageId: _stringOrNull(data['messageId']),
      callId: _stringOrNull(data['callId']),
      kind: _stringOrNull(data['kind']),
      title: _stringOrNull(data['title']) ?? '',
      body: _stringOrNull(data['body']) ?? '',
      mention: data['mention'] == 'true',
      reply: data['reply'] == 'true',
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    return s.isEmpty ? null : s;
  }
}

class FcmTokenRegistration {
  final Future<String?> Function() tokenProvider;
  final Future<void> Function(String token) save;

  const FcmTokenRegistration({required this.tokenProvider, required this.save});
}

/// Client-side FCM lifecycle management.
/// - Initialises Firebase (using the generated firebase_options.dart).
/// - Registers the device token with the Supabase `device_tokens` table.
/// - Listens for foreground / background / terminated notifications.
/// - Exposes notification taps so the router can navigate to the target.
///
/// Sending push messages is server-side (see Supabase Edge Function
/// `send-push`); no Firebase credentials ever ship in the app.
class NotificationService {
  NotificationService({
    void Function(NotificationPayload payload, NotificationSource source)?
        onLaunch,
    required this.tokenRegistration,
  }) : onLaunch = onLaunch ?? ((p, s) {});

  void Function(NotificationPayload payload, NotificationSource source)
      onLaunch;
  final FcmTokenRegistration tokenRegistration;

  StreamSubscription<String>? _tokenRefreshSub;

  static final _notificationController =
      StreamController<NotificationPayload>.broadcast();

  static final _tapController = StreamController<NotificationPayload>.broadcast();

  /// Notifications received while the app is running.
  static Stream<NotificationPayload> get onNotification =>
      _notificationController.stream;

  /// User tapped a notification (foreground, background, or terminated).
  static Stream<NotificationPayload> get onNotificationTap =>
      _tapController.stream;

  Future<void> initialize() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    // Register the current token and keep it fresh on refresh.
    await _registerCurrentToken(messaging);
    _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
      await tokenRegistration.save(token);
    });

    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      final payload = _buildPayload(message);
      if (payload != null) {
        _notificationController.add(payload);
      }
    });

    // Background (user launched the app by tapping a notification)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      final payload = _buildPayload(message);
      if (payload != null) {
        _tapController.add(payload);
        onLaunch(payload, NotificationSource.terminated);
      }
    });

    // Background / terminated while running in memory
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = _buildPayload(message);
      if (payload != null) {
        _tapController.add(payload);
        onLaunch(payload, NotificationSource.background);
      }
    });
  }

  Future<void> _registerCurrentToken(FirebaseMessaging messaging) async {
    await tokenRegistration.save((await messaging.getToken()) ?? '');
  }

  NotificationPayload? _buildPayload(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) {
      return NotificationPayload(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );
    }
    return NotificationPayload.fromData(data);
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
  }
}

enum NotificationSource { foreground, background, terminated }

Future<void> handleBackgroundFcm(RemoteMessage message) async {
  // No-op: background handling is fully server-driven. Kept for completeness.
}