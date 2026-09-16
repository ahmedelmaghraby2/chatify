enum MessageStatus { pending, sent, delivered, seen, failed, retrying }

class ChatMessage {
  const ChatMessage({required this.id, required this.clientId, required this.conversationId, required this.senderId, required this.body, required this.createdAt, required this.status, this.replyToId, this.editedAt, this.deletedAt});
  final String id, clientId, conversationId, senderId, body;
  final DateTime createdAt;
  final MessageStatus status;
  final String? replyToId;
  final DateTime? editedAt, deletedAt;
  bool get isDeleted => deletedAt != null;
}
