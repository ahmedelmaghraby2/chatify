import 'package:chatify/domain/entities/attachment.dart';

import '../dto/attachment_dto.dart';

extension AttachmentDtoMapper on AttachmentDto {
  Attachment toEntity() {
    return Attachment(
      id: id,
      messageId: messageId,
      bucket: bucket,
      path: path,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      durationMs: durationMs,
      width: width,
      height: height,
    );
  }
}
