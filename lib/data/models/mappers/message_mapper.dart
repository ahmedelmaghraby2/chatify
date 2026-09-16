import 'package:chatify/domain/entities/message.dart';
import 'package:chatify/domain/entities/reaction.dart';

import '../dto/message_dto.dart';
import '../dto/reaction_dto.dart';
import 'attachment_mapper.dart';

extension MessageDtoMapper on MessageDto {
  Message toEntity() {
    return Message(
      id: id,
      clientId: clientId,
      conversationId: conversationId,
      senderId: senderId,
      kind: _parseKind(kind),
      body: body,
      replyToId: replyToId,
      editedAt: editedAt,
      deletedAt: deletedAt,
      createdAt: createdAt,
      status: _parseStatus(status),
      senderName: senderDisplayName,
      senderAvatarUrl: senderAvatarPath,
      reactions: reactions.map((e) => e.toEntity()).toList(),
      attachments: attachments.map((e) => e.toEntity()).toList(),
    );
  }

  MessageKind _parseKind(String kind) {
    switch (kind) {
      case 'image':
        return MessageKind.image;
      case 'video':
        return MessageKind.video;
      case 'document':
        return MessageKind.document;
      case 'voice':
        return MessageKind.voice;
      case 'system':
        return MessageKind.system;
      default:
        return MessageKind.text;
    }
  }

  MessageStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return MessageStatus.pending;
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'seen':
        return MessageStatus.seen;
      case 'failed':
        return MessageStatus.failed;
      case 'retrying':
        return MessageStatus.retrying;
      default:
        return MessageStatus.sending;
    }
  }
}

extension ReactionDtoMapper on ReactionDto {
  Reaction toEntity() {
    return Reaction(
      messageId: messageId,
      userId: userId,
      emoji: emoji,
      createdAt: createdAt,
    );
  }
}
