import 'dart:async';

import '../entities/message.dart';
import '../entities/attachment.dart';

abstract class MessageRepository {
  Stream<List<Message>> watchMessages(String conversationId);

  Future<List<Message>> loadInitial(String conversationId);

  Future<List<Message>> loadOlder(String conversationId, {DateTime? before});

  Future<List<Message>> loadAround(String conversationId, String messageId);

  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    required MessageKind kind,
    String? replyToId,
    List<Attachment>? attachments,
  });

  Future<Message> editMessage(String messageId, String body);

  Future<void> deleteForMe(String messageId);

  Future<void> deleteForEveryone(String messageId);

  Future<void> addReaction(String messageId, String emoji);

  Future<void> removeReaction(String messageId, String emoji);

  Future<void> markAsDelivered(String conversationId, String messageId);

  Future<void> markAsSeen(String conversationId, String messageId);

  Future<List<Message>> searchMessages(String conversationId, String query);

  Future<Message?> getMessage(String messageId);
}
