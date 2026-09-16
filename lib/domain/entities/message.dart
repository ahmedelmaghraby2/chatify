import 'package:equatable/equatable.dart';
import 'attachment.dart';
import 'reaction.dart';

enum MessageKind { text, image, video, document, voice, system }

enum MessageStatus { pending, sending, sent, delivered, seen, failed, retrying }

class Message extends Equatable {
  final String id;
  final String clientId;
  final String conversationId;
  final String senderId;
  final MessageKind kind;
  final String? body;
  final String? replyToId;
  final Message? replyTo;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final MessageStatus status;
  final List<Reaction> reactions;
  final List<Attachment> attachments;
  final String? senderName;
  final String? senderAvatarUrl;

  const Message({
    required this.id,
    required this.clientId,
    required this.conversationId,
    required this.senderId,
    this.kind = MessageKind.text,
    this.body,
    this.replyToId,
    this.replyTo,
    this.editedAt,
    this.deletedAt,
    required this.createdAt,
    this.status = MessageStatus.sending,
    this.reactions = const [],
    this.attachments = const [],
    this.senderName,
    this.senderAvatarUrl,
  });

  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;
  bool get isPending =>
      status == MessageStatus.pending || status == MessageStatus.sending;
  bool get isFailed => status == MessageStatus.failed;
  bool get isRetrying => status == MessageStatus.retrying;
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isSeen => status == MessageStatus.seen;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get isReply => replyToId != null;
  bool get isText => kind == MessageKind.text;
  bool get isImage => kind == MessageKind.image;
  bool get isVideo => kind == MessageKind.video;
  bool get isDocument => kind == MessageKind.document;
  bool get isVoice => kind == MessageKind.voice;
  bool get isSystem => kind == MessageKind.system;

  Message copyWith({
    String? id,
    String? clientId,
    String? conversationId,
    String? senderId,
    MessageKind? kind,
    String? Function()? body,
    String? Function()? replyToId,
    Message? Function()? replyTo,
    DateTime? Function()? editedAt,
    DateTime? Function()? deletedAt,
    DateTime? createdAt,
    MessageStatus? status,
    List<Reaction>? reactions,
    List<Attachment>? attachments,
    String? Function()? senderName,
    String? Function()? senderAvatarUrl,
  }) => Message(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    kind: kind ?? this.kind,
    body: body != null ? body() : this.body,
    replyToId: replyToId != null ? replyToId() : this.replyToId,
    replyTo: replyTo != null ? replyTo() : this.replyTo,
    editedAt: editedAt != null ? editedAt() : this.editedAt,
    deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    reactions: reactions ?? this.reactions,
    attachments: attachments ?? this.attachments,
    senderName: senderName != null ? senderName() : this.senderName,
    senderAvatarUrl:
        senderAvatarUrl != null ? senderAvatarUrl() : this.senderAvatarUrl,
  );

  @override
  List<Object?> get props => [
        id,
        clientId,
        conversationId,
        senderId,
        kind,
        body,
        status,
        editedAt,
        deletedAt,
        reactions,
        attachments,
      ];
}
