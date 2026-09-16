import 'dart:async';

import '../entities/conversation.dart';

abstract class ConversationRepository {
  Stream<List<Conversation>> watchConversations();

  Future<List<Conversation>> searchConversations(String query);

  Future<Conversation> getConversation(String id);

  Future<String> createDirectConversation(String otherUserId);

  Future<String> createGroupConversation({
    required String title,
    String description = '',
  });

  Future<void> updateGroup({
    required String conversationId,
    String? title,
    String? description,
    String? avatarPath,
  });

  Future<void> addMembers(String conversationId, List<String> userIds);

  Future<void> removeMember(String conversationId, String userId);

  Future<void> leaveGroup(String conversationId);

  Future<void> promoteToAdmin(String conversationId, String userId);

  Future<void> demoteFromAdmin(String conversationId, String userId);

  Future<void> pinConversation(String conversationId);

  Future<void> unpinConversation(String conversationId);

  Future<void> muteConversation(String conversationId, Duration duration);

  Future<void> unmuteConversation(String conversationId);

  Future<void> archiveConversation(String conversationId);

  Future<void> unarchiveConversation(String conversationId);

  Future<void> clearConversation(String conversationId);

  Future<void> deleteConversation(String conversationId);

  Future<void> blockUser(String userId);

  Future<void> unblockUser(String userId);

  Stream<List<String>> watchTypingUsers(String conversationId);

  void startTyping(String conversationId);

  void stopTyping(String conversationId);

  Stream<Map<String, bool>> watchPresence(List<String> userIds);
}
