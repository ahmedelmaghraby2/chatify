class AttachmentDto {
  final String id;
  final String messageId;
  final String bucket;
  final String path;
  final String? mimeType;
  final int? sizeBytes;
  final int? durationMs;
  final int? width;
  final int? height;

  const AttachmentDto({
    required this.id,
    required this.messageId,
    required this.bucket,
    required this.path,
    this.mimeType,
    this.sizeBytes,
    this.durationMs,
    this.width,
    this.height,
  });

  factory AttachmentDto.fromMap(Map<String, dynamic> map) {
    return AttachmentDto(
      id: map['id'] as String? ?? '',
      messageId: map['message_id'] as String? ?? '',
      bucket: map['bucket'] as String? ?? '',
      path: map['path'] as String? ?? '',
      mimeType: map['mime_type'] as String?,
      sizeBytes: (map['size_bytes'] as num?)?.toInt(),
      durationMs: (map['duration_ms'] as num?)?.toInt(),
      width: (map['width'] as num?)?.toInt(),
      height: (map['height'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'bucket': bucket,
      'path': path,
      'mime_type': mimeType,
      'size_bytes': sizeBytes,
      'duration_ms': durationMs,
      'width': width,
      'height': height,
    };
  }
}
