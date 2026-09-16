/// Compile with `--dart-define-from-file=configurations/.env`.
/// No secrets are embedded in source or shipped through version control.
class AppConfig {
  const AppConfig._();
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const stunUrl = String.fromEnvironment('WEBRTC_STUN_URL', defaultValue: 'stun:stun.l.google.com:19302');
  static const turnUrl = String.fromEnvironment('WEBRTC_TURN_URL');
  static const turnUsername = String.fromEnvironment('WEBRTC_TURN_USERNAME');
  static const turnCredential = String.fromEnvironment('WEBRTC_TURN_CREDENTIAL');
  static bool get configured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
