import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, User;

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/supabase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required SupabaseAuthDatasource datasource})
      : _datasource = datasource;

  final SupabaseAuthDatasource _datasource;

  User? _currentUser;

  @override
  User? get currentUser => _currentUser ?? _mapUser(_datasource.currentAuthUser);

  @override
  Stream<AuthState> get onAuthStateChange {
    return _datasource.onAuthStateChange.map<AuthState>((authEvent) {
      final user = _mapUser(authEvent.session?.user);
      _currentUser = user;
      return AuthState(event: _mapEvent(authEvent.event), user: user);
    });
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    try {
      final response = await _datasource.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (username != null) 'username': username,
        },
      );
      _currentUser = _mapUser(response.user);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _datasource.signInWithPassword(
        email: email,
        password: password,
      );
      _currentUser = _mapUser(response.user);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _datasource.signOut();
      _currentUser = null;
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _datasource.resetPasswordForEmail(email);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarPath,
  }) async {
    final authUser = _datasource.currentAuthUser;
    if (authUser == null) {
      throw const AuthFailure(message: 'No authenticated user');
    }

    try {
      if (displayName != null || username != null) {
        await _datasource.updateUser(data: {
          if (displayName != null) 'display_name': displayName,
          if (username != null) 'username': username,
        });
      }
      if (bio != null || avatarPath != null) {
        await _datasource.updateProfileRow(authUser.id, {
          if (bio != null) 'bio': bio,
          if (avatarPath != null) 'avatar_path': avatarPath,
        });
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> restoreSession() async {
    try {
      _currentUser = _mapUser(_datasource.currentAuthUser);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  User? _mapUser(dynamic authUser) {
    if (authUser == null) return null;
    final meta = (authUser.userMetadata as Map<String, dynamic>?) ?? const {};
    return User(
      id: authUser.id as String,
      username: (meta['username'] as String?) ??
          (authUser.email as String?) ??
          '',
      displayName: (meta['display_name'] as String?) ??
          (authUser.email as String?) ??
          'User',
      avatarUrl: (meta['avatar_url'] as String?) ??
          (meta['avatar_path'] as String?),
      bio: meta['bio'] as String?,
      createdAt: (authUser.createdAt as DateTime?) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  AuthEventType _mapEvent(AuthChangeEvent event) {
    switch (event) {
      case AuthChangeEvent.signedIn:
        return AuthEventType.signedIn;
      case AuthChangeEvent.signedOut:
        return AuthEventType.signedOut;
      case AuthChangeEvent.tokenRefreshed:
        return AuthEventType.tokenRefreshed;
      case AuthChangeEvent.passwordRecovery:
        return AuthEventType.passwordReset;
      default:
        return AuthEventType.tokenRefreshed;
    }
  }

  Failure _mapError(Object e) {
    final message = e.toString();
    if (e is AuthException) {
      return AuthFailure(message: e.message);
    }
    if (_isNetworkError(message)) {
      return NetworkFailure(message: message);
    }
    return UnknownFailure(message: message);
  }

  bool _isNetworkError(String message) {
    final lowered = message.toLowerCase();
    const hints = [
      'socketexception',
      'connection refused',
      'connection reset',
      'failed host',
      'timeout',
      'network',
      'internet',
      'clientexception',
    ];
    return hints.any(lowered.contains);
  }
}