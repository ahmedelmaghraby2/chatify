import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageDatasource {
  SupabaseStorageDatasource(this._client);
  final SupabaseClient _client;

  Future<String> uploadAvatar(
    String userId,
    Uint8List bytes,
    String ext,
  ) async {
    final path = '$userId/avatar.$ext';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return path;
  }

  Future<String> uploadChatMedia(
    String conversationId,
    String fileName,
    Uint8List bytes,
    String mimeType,
  ) async {
    final path = '$conversationId/$fileName';
    await _client.storage
        .from('chat-media')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );
    return path;
  }

  Future<String> uploadVoiceMessage(
    String conversationId,
    String fileName,
    Uint8List bytes,
  ) async {
    final path = '$conversationId/$fileName';
    await _client.storage
        .from('voice-messages')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'audio/aac'),
        );
    return path;
  }

  Future<String> uploadDocument(
    String conversationId,
    String fileName,
    Uint8List bytes,
    String mimeType,
  ) async {
    final path = '$conversationId/$fileName';
    await _client.storage
        .from('documents')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );
    return path;
  }

  Future<Uint8List?> downloadFile(String bucket, String path) async {
    return await _client.storage.from(bucket).download(path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
