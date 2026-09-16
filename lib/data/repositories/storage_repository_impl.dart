import 'dart:typed_data';

import '../../core/errors/failures.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/remote/supabase_storage_datasource.dart';

class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl({required SupabaseStorageDatasource datasource})
      : _datasource = datasource;

  final SupabaseStorageDatasource _datasource;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    try {
      return await _datasource.uploadAvatar(userId, bytes, extension);
    } catch (e) {
      throw UploadFailure(message: e.toString());
    }
  }

  @override
  Future<String> uploadChatMedia({
    required String conversationId,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      return await _datasource.uploadChatMedia(
        conversationId,
        path,
        bytes,
        mimeType,
      );
    } catch (e) {
      throw UploadFailure(message: e.toString());
    }
  }

  @override
  Future<String> uploadVoiceMessage({
    required String conversationId,
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      return await _datasource.uploadVoiceMessage(conversationId, path, bytes);
    } catch (e) {
      throw UploadFailure(message: e.toString());
    }
  }

  @override
  Future<String> uploadDocument({
    required String conversationId,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      return await _datasource.uploadDocument(
        conversationId,
        path,
        bytes,
        mimeType,
      );
    } catch (e) {
      throw UploadFailure(message: e.toString());
    }
  }

  @override
  Future<Uint8List?> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      return await _datasource.downloadFile(bucket, path);
    } catch (e) {
      throw StorageFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _datasource.deleteFile(bucket, path);
    } catch (e) {
      throw StorageFailure(message: e.toString());
    }
  }

  @override
  String getPublicUrl(String bucket, String path) {
    return _datasource.getPublicUrl(bucket, path);
  }
}