# Chatify

Run on a mobile device with local configuration:

`flutter run --dart-define-from-file=configurations/.env`

Apply schema changes with `supabase db push`. Deploy notification handling with `supabase functions deploy send-push`; configure the required FCM service-account secret in Supabase, never in this repository or the mobile client.

For iOS, download `GoogleService-Info.plist` from the existing Firebase project and add it to `ios/Runner` in Xcode. Android configuration is already included.

The client uses the configured STUN URL by default. Add TURN settings to the local environment before production deployment.
