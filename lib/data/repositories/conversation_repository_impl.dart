import 'dart:async';

import '../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/local/local_conversation_dao.dart';
import '../datasources/remote/supabase_auth_datasource.dart';
import '../datasources/remote/supabase_conversation_datasource.dart';
import '../models/dto/conversation_dto.dart';
import '../models/dto/message_dto.dart';
import '../models/mappers/conversation_mapper.dart';
import '../models/mappers/message_mapper.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl({
    required SupabaseConversationDatasource datasource,
    required LocalConversationDao localDao,
    required SupabaseAuthDatasource authDatasource,
  })  : _datasource = datasource,
        _localDao = localDao,
        _authDatasource = authDatasource;

  final SupabaseConversationDatasource _datasource;
  final LocalConversationDao _localDao;
  final SupabaseAuthDatasource _authDatasource;

  @override
  Stream<List<Conversation>> watchConversations() async* {
    try {
      final cached = await _localDao.getConversations();
      if (cached.isNotEmpty) {
        yield cached.map(_mapConversation).toList();
      }
    } catch (_) {}

    try {
      final userId = _requireUserId();
      final rows = await _datasource.loadConversations(userId);
      await _localDao.saveConversations(rows);
      yield rows.map(_mapConversation).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<List<Conversation>> searchConversations(String query) async {
    final userId = _requireUserId();
    try {
      final rows = await _datasource.searchConversations(userId, query);
      return rows.map(_mapConversation).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<Conversation> getConversation(String id) async {
    try {
      final local = await _localDao.getConversation(id);
      if (local != null) return _mapConversation(local);
    } catch (_) {}

    try {
      final remote = await _datasource.getConversation(id);
      if (remote == null) throw const NotFoundFailure();
      await _localDao.saveConversations([remote]);
      return _mapConversation(remote);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<String> createDirectConversation(String otherUserId) async {
    final userId = _requireUserId();
    try {
      final result = await _datasource.createDirectConversation(
        userId,
        otherUserId,
      );
      final id = _extractConversationId(result);
      await _localDao.saveConversations([
        {
          'id': id,
          'kind': 'direct',
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'created_by': userId,
        },
      ]);
      return id;
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<String> createGroupConversation({
    required String title,
    String description = '',
  }) async {
    final userId = _requireUserId();
    try {
      final result = await _datasource.createGroupConversation(
        userId,
        title,
        description,
      );
      final id = _extractConversationId(result);
      await _localDao.saveConversations([
        {
          'id': id,
          'kind': 'group',
          'title': title,
          'description': description,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'created_by': userId,
        },
      ]);
      return id;
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> updateGroup({
    required String conversationId,
    String? title,
    String? description,
    String? avatarPath,
  }) {
    return _delegate(() => _datasource.updateGroup(conversationId, {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (avatarPath != null) 'avatar_path': avatarPath,
        }));
  }

  @override
  Future<void> addMembers(String conversationId, List<String> userIds) {
    return _delegate(() => _datasource.addMembers(conversationId, userIds));
  }

  @override
  Future<void> removeMember(String conversationId, String userId) {
    return _delegate(() => _datasource.removeMember(conversationId, userId));
  }

  @override
  Future<void> leaveGroup(String conversationId) {
    final userId = _requireUserId();
    return _delegate(() => _datasource.removeMember(conversationId, userId));
  }

  @override
  Future<void> promoteToAdmin(String conversationId, String userId) {
    return _delegate(() => _datasource.promoteToAdmin(conversationId, userId));
  }

  @override
  Future<void> demoteFromAdmin(String conversationId, String userId) {
    return _delegate(() => _datasource.demoteFromAdmin(conversationId, userId));
  }

  @override
  Future<void> pinConversation(String conversationId) {
    return _delegate(() => _datasource.pin(conversationId));
  }

  @override
  Future<void> unpinConversation(String conversationId) {
    return _delegate(() => _datasource.unpin(conversationId));
  }

  @override
  Future<void> muteConversation(String conversationId, Duration duration) {
    return _delegate(
        () => _datasource.mute(conversationId, duration: duration));
  }

  @override
  Future<void> unmuteConversation(String conversationId) {
    return _delegate(() => _datasource.unmute(conversationId));
  }

  @override
  Future<void> archiveConversation(String conversationId) {
    return _delegate(() => _datasource.archive(conversationId));
  }

  @override
  Future<void> unarchiveConversation(String conversationId) {
    return _delegate(() => _datasource.unarchive(conversationId));
  }

  @override
  Future<void> clearConversation(String conversationId) {
    return _delegate(() => _datasource.clear(conversationId));
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _datasource.delete(conversationId);
      await _localDao.deleteConversation(conversationId);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> blockUser(String userId) {
    final currentUserId = _requireUserId();
    return _delegate(() => _datasource.blockUser(currentUserId, userId));
  }

  @override
  Future<void> unblockUser(String userId) {
    final currentUserId = _requireUserId();
    return _delegate(() => _datasource.unblockUser(currentUserId, userId));
  }

  @override
  Stream<List<String>> watchTypingUsers(String conversationId) {
    return _datasource.watchTypingUsers(conversationId).map(
          (users) => users
              .map((u) => u['user_id'] as String? ?? '')
              .where((u) => u.isNotEmpty)
              .toList(),
        );
  }

  @override
  void startTyping(String conversationId) {
    final userId = _requireUserId();
    _datasource.sendTypingEvent(conversationId, userId, true);
  }

  @override
  void stopTyping(String conversationId) {
    final userId = _requireUserId();
    _datasource.sendTypingEvent(conversationId, userId, false);
  }

  @override
  Stream<Map<String, bool>> watchPresence(List<String> userIds) {
    return _datasource.watchPresence(userIds).map(
          (onlineUsers) => {
            for (final id in userIds) id: onlineUsers.contains(id),
          },
        );
  }

  String _requireUserId() {
    final userId = _authDatasource.currentAuthUser?.id;
    if (userId == null) {
      throw const AuthFailure(message: 'User is not authenticated');
    }
    return userId;
  }

  String _extractConversationId(Map<String, dynamic> result) {
    final id = result['id'] ?? result['conversation_id'];
    if (id is String && id.isNotEmpty) return id;
    throw const UnknownFailure(
      message: 'Conversation was created but its id could not be resolved',
    );
  }

  Conversation _mapConversation(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    final profile = normalized['member_profile'];
    if (profile is Map<String, dynamic>) {
      final userMap = Map<String, dynamic>.from(profile);
      final avatarUrl = userMap['avatar_url'];
      if (avatarUrl != null && userMap['avatar_path'] == null) {
        userMap['avatar_path'] = avatarUrl;
      }
      normalized['other_user'] = userMap;
    }

    var conversation = ConversationDto.fromMap(normalized).toEntity();

    final lastMessageMap = normalized['last_message'];
    if (lastMessageMap is Map<String, dynamic>) {
      final messageMap = Map<String, dynamic>.from(lastMessageMap);
      messageMap.putIfAbsent('conversation_id', () => conversation.id);
      final Message lastMessage = MessageDto.fromMap(messageMap).toEntity();
      conversation = conversation.copyWith(lastMessage: () => lastMessage);
    }

    return conversation;
  }

  Future<void> _delegate(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  Failure _mapError(Object e) {
    final message = e.toString();
    if (_isNetworkError(message)) {
      return NetworkFailure(message: message);
    }
    return UnknownFailure(message: message);
  }

  bool _isNetworkError(String message) {
    final lowered = message.toLowerCase();
    const hints = [
      'socketexception',
      'connection refused',
      'connection reset',
      'failed host',
      'timeout',
      'network',
      'internet',
      'clientexception',
    ];
    return hints.any(lowered.contains);
  }
}