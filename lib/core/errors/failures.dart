abstract class Failure {
  final String message;
  const Failure({this.message = 'An unexpected error occurred'});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network connection error'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication error'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation error'});
}

class StorageFailure extends Failure {
  const StorageFailure({super.message = 'Storage error'});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({super.message = 'Database error'});
}

class RealtimeFailure extends Failure {
  const RealtimeFailure({super.message = 'Realtime connection error'});
}

class UploadFailure extends Failure {
  const UploadFailure({super.message = 'Upload failed'});
}

class AudioFailure extends Failure {
  const AudioFailure({super.message = 'Audio error'});
}

class CallFailure extends Failure {
  const CallFailure({super.message = 'Call error'});
}

class SyncFailure extends Failure {
  const SyncFailure({super.message = 'Sync error'});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}
