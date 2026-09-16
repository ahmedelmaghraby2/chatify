import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/di/dependencies.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/pending_operation_sync.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseKey,
  );

  await Dependencies.register();

  // FCM: register token + notification listeners (mobile only).
  if (!kIsWeb) {
    await sl.get<NotificationService>().initialize();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundFcm);
  }

  // Presence + pending-sync are started once we know there is a session.
  final pendingSync = sl.get<PendingOperationSync>();
  pendingSync.start();

  runApp(const ChatifyApp());
}