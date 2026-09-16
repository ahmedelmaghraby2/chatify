import 'attachment_dto.dart';
import 'reaction_dto.dart';

class MessageDto {
  final String id;
  final String clientId;
  final String conversationId;
  final String senderId;
  final String kind;
  final String? body;
  final String? replyToId;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final String status;
  final String? senderDisplayName;
  final String? senderAvatarPath;
  final List<ReactionDto> reactions;
  final List<AttachmentDto> attachments;

  const MessageDto({
    required this.id,
    required this.clientId,
    required this.conversationId,
    required this.senderId,
    this.kind = 'text',
    this.body,
    this.replyToId,
    this.editedAt,
    this.deletedAt,
    required this.createdAt,
    this.status = 'sending',
    this.senderDisplayName,
    this.senderAvatarPath,
    this.reactions = const [],
    this.attachments = const [],
  });

  factory MessageDto.fromMap(Map<String, dynamic> map) {
    return MessageDto(
      id: map['id'] as String? ?? '',
      clientId: map['client_id'] as String? ?? '',
      conversationId: map['conversation_id'] as String? ?? '',
      senderId: map['sender_id'] as String? ?? '',
      kind: map['kind'] as String? ?? 'text',
      body: map['body'] as String?,
      replyToId: map['reply_to_id'] as String?,
      editedAt: map['edited_at'] != null
          ? DateTime.parse(map['edited_at'] as String)
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      status: map['status'] as String? ?? 'sending',
      senderDisplayName: map['sender_display_name'] as String?,
      senderAvatarPath: map['sender_avatar_path'] as String?,
      reactions: (map['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionDto.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attachments: (map['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentDto.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'kind': kind,
      'body': body,
      'reply_to_id': replyToId,
      'edited_at': editedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'sender_display_name': senderDisplayName,
      'sender_avatar_path': senderAvatarPath,
      'reactions': reactions.map((e) => e.toMap()).toList(),
      'attachments': attachments.map((e) => e.toMap()).toList(),
    };
  }
}
