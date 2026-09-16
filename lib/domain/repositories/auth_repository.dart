import 'dart:async';

import '../entities/user.dart';

enum AuthEventType { signedIn, signedOut, tokenRefreshed, passwordReset }

class AuthState {
  final AuthEventType event;
  final User? user;

  const AuthState({required this.event, this.user});
}

abstract class AuthRepository {
  User? get currentUser;

  Stream<AuthState> get onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
    String? username,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarPath,
  });

  Future<void> restoreSession();
}
