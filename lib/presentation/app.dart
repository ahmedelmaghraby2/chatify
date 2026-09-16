import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'auth/auth_bloc.dart';
import 'router/app_router.dart';
import 'settings/settings_cubit.dart';

/// Bridges a [Stream] into a [Listenable] so GoRouter can refresh
/// its redirect with an `Bloc`-driven signal.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  StreamSubscription<Object?>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Root application widget.
class ChatifyApp extends StatefulWidget {
  const ChatifyApp({super.key});

  @override
  State<ChatifyApp> createState() => _ChatifyAppState();
}

class _ChatifyAppState extends State<ChatifyApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  late final _StreamListenable _authListenable;
  NotificationService? _notifications;

  @override
  void initState() {
    super.initState();
    _authBloc = sl.get<AuthBloc>();
    _authListenable = _StreamListenable(_authBloc.stream);
    _authBloc.add(AppStarted());
    _router = buildRouter(
      isAuthenticated: () =>
          _authBloc.state.status == AuthStatus.authenticated,
      refreshListenable: _authListenable,
    );
    _wireNotifications();
  }

  void _wireNotifications() {
    if (!sl.isRegistered<NotificationService>()) return;
    _notifications = sl.get<NotificationService>();
    _notifications!.onLaunch = (payload, source) {
      final conversationId = payload.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        _router.push(AppRoutes.chatWith(conversationId));
      } else if (payload.callId != null && payload.callId!.isNotEmpty) {
        _router.push('${AppRoutes.activeCall}/${payload.callId}');
      }
    };
    NotificationService.onNotificationTap.listen((payload) {
      final conversationId = payload.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        _router.push(AppRoutes.chatWith(conversationId));
      }
    });
    NotificationService.onNotification.listen((payload) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              payload.title.isEmpty ? payload.body : '${payload.title}: ${payload.body}',
            ),
          ),
        );
    });
  }

  @override
  void dispose() {
    _authListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsCubit = sl.get<SettingsCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: Locale(settings.localeCode),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}