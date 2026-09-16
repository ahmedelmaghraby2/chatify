import 'dart:typed_data';

abstract class StorageRepository {
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String extension,
  });

  Future<String> uploadChatMedia({
    required String conversationId,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<String> uploadVoiceMessage({
    required String conversationId,
    required String path,
    required Uint8List bytes,
  });

  Future<String> uploadDocument({
    required String conversationId,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<Uint8List?> downloadFile({
    required String bucket,
    required String path,
  });

  Future<void> deleteFile({
    required String bucket,
    required String path,
  });

  String getPublicUrl(String bucket, String path);
}
