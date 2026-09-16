import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthDatasource {
  SupabaseAuthDatasource(this._client);
  final SupabaseClient _client;

  User? get currentAuthUser => _client.auth.currentUser;
  GoTrueClient get auth => _client.auth;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) =>
      _client.auth.signUp(email: email, password: password, data: data);

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPasswordForEmail(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<UserResponse> updateUser({Map<String, dynamic>? data}) =>
      _client.auth.updateUser(UserAttributes(data: data));

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final data = await _client
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,display_name.ilike.%$query%')
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateProfileRow(String userId, Map<String, dynamic> updates) =>
      _client.from('profiles').update(updates).eq('id', userId);
}
