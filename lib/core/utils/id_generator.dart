import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();

  static String generateClientId() => 'client_${_uuid.v4()}';

  static String generateTempId() => 'temp_${_uuid.v4()}';
}
