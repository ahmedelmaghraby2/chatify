import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/call_service.dart';
import '../services/app_settings.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';
import '../di/service_locator.dart';
import '../../presentation/auth/auth_bloc.dart';
import '../../presentation/settings/settings_cubit.dart';
import '../../data/datasources/local/local_conversation_dao.dart';
import '../../data/datasources/local/local_database.dart';
import '../../data/datasources/local/local_message_dao.dart';
import '../../data/datasources/remote/supabase_auth_datasource.dart';
import '../../data/datasources/remote/supabase_call_datasource.dart';
import '../../data/datasources/remote/supabase_conversation_datasource.dart';
import '../../data/datasources/remote/supabase_message_datasource.dart';
import '../../data/datasources/remote/supabase_presence_datasource.dart';
import '../../data/datasources/remote/supabase_storage_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/call_repository_impl.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/pending_operation_sync.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/call_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/storage_repository.dart';

class Dependencies {
  Dependencies._();

  /// Register the full dependency graph. Must be called after
  /// `Supabase.initialize` and after `SharedPreferences` is available.
  static Future<void> register() async {
    final client = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();

    // ── Infrastructure ──────────────────────────────────────────
    sl.register<SupabaseClient>(client);
    sl.register<ConnectivityService>(ConnectivityService());
    sl.register<LocalDatabase>(LocalDatabase());
    sl.register<AppSettings>(AppSettings(prefs));

    // ── Datasources ─────────────────────────────────────────────
    sl.register<SupabaseAuthDatasource>(SupabaseAuthDatasource(client));
    sl.register<SupabaseConversationDatasource>(
      SupabaseConversationDatasource(client),
    );
    sl.register<SupabaseMessageDatasource>(SupabaseMessageDatasource(client));
    sl.register<SupabaseStorageDatasource>(SupabaseStorageDatasource(client));
    sl.register<SupabaseCallDatasource>(SupabaseCallDatasource(client));
    sl.register<SupabasePresenceDatasource>(SupabasePresenceDatasource(client));

    // ── Local DAOs ──────────────────────────────────────────────
    final db = sl.get<LocalDatabase>();
    sl.register<LocalConversationDao>(LocalConversationDao(db));
    sl.register<LocalMessageDao>(LocalMessageDao(db));

    // ── Repositories ────────────────────────────────────────────
    final authDatasource = sl.get<SupabaseAuthDatasource>();

    sl.register<AuthRepository>(
      AuthRepositoryImpl(datasource: authDatasource),
    );
    sl.register<ConversationRepository>(
      ConversationRepositoryImpl(
        datasource: sl.get<SupabaseConversationDatasource>(),
        localDao: sl.get<LocalConversationDao>(),
        authDatasource: authDatasource,
      ),
    );
    sl.register<MessageRepository>(
      MessageRepositoryImpl(
        datasource: sl.get<SupabaseMessageDatasource>(),
        localDao: sl.get<LocalMessageDao>(),
        authDatasource: authDatasource,
      ),
    );
    sl.register<StorageRepository>(
      StorageRepositoryImpl(
        datasource: sl.get<SupabaseStorageDatasource>(),
      ),
    );
    sl.register<CallRepository>(
      CallRepositoryImpl(
        datasource: sl.get<SupabaseCallDatasource>(),
        authDatasource: authDatasource,
      ),
    );

    // ── Application services ────────────────────────────────────
    sl.register<PendingOperationSync>(
      PendingOperationSync(
        localDao: sl.get<LocalMessageDao>(),
        messageDatasource: sl.get<SupabaseMessageDatasource>(),
      ),
    );
    sl.register<WebRtcCallManager>(WebRtcCallManager());

    sl.register<NotificationService>(
      NotificationService(
        tokenRegistration: FcmTokenRegistration(
          tokenProvider: () async => FirebaseMessaging.instance.getToken(),
          save: (token) async {
            if (token.isEmpty) return;
            final userId = client.auth.currentUser?.id;
            if (userId == null || userId.isEmpty) return;
            final platform = Platform.isAndroid
                ? 'android'
                : Platform.isIOS
                    ? 'ios'
                    : 'other';
            await client.from('device_tokens').upsert({
              'user_id': userId,
              'token': token,
              'platform': platform,
            }, onConflict: 'token');
          },
        ),
      ),
    );

    // ── Presentation services ───────────────────────────────────
    sl.register<AuthBloc>(AuthBloc(sl.get<AuthRepository>()));
    sl.register<SettingsCubit>(SettingsCubit(sl.get<AppSettings>()));
  }
}