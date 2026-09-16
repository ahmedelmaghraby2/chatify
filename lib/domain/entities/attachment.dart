import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String messageId;
  final String bucket;
  final String path;
  final String? mimeType;
  final int? sizeBytes;
  final int? durationMs;
  final int? width;
  final int? height;
  final double? uploadProgress;

  const Attachment({
    required this.id,
    required this.messageId,
    required this.bucket,
    required this.path,
    this.mimeType,
    this.sizeBytes,
    this.durationMs,
    this.width,
    this.height,
    this.uploadProgress,
  });

  bool get isUploading => uploadProgress != null && uploadProgress! < 1.0;
  bool get isImage => mimeType?.startsWith('image/') ?? false;
  bool get isVideo => mimeType?.startsWith('video/') ?? false;
  bool get isAudio => mimeType?.startsWith('audio/') ?? false;

  Attachment copyWith({
    String? id,
    String? messageId,
    String? bucket,
    String? path,
    String? Function()? mimeType,
    int? Function()? sizeBytes,
    int? Function()? durationMs,
    int? Function()? width,
    int? Function()? height,
    double? Function()? uploadProgress,
  }) => Attachment(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    bucket: bucket ?? this.bucket,
    path: path ?? this.path,
    mimeType: mimeType != null ? mimeType() : this.mimeType,
    sizeBytes: sizeBytes != null ? sizeBytes() : this.sizeBytes,
    durationMs: durationMs != null ? durationMs() : this.durationMs,
    width: width != null ? width() : this.width,
    height: height != null ? height() : this.height,
    uploadProgress: uploadProgress != null ? uploadProgress() : this.uploadProgress,
  );

  @override
  List<Object?> get props => [id, messageId, bucket, path, mimeType, sizeBytes, uploadProgress];
}
