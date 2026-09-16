import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConversationDatasource {
  SupabaseConversationDatasource(this._client);
  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> loadConversations(String userId) async {
    final data = await _client
        .from('conversation_members')
        .select('''
          conversation_id,
          conversations (
            id, kind, title, description, avatar_path, created_by,
            last_message_at, pinned_at, muted_until, archived_at,
            created_at, deleted_at
          ),
          profiles!conversation_members_user_id_fkey (
            id, username, display_name, avatar_url
          )
        ''')
        .eq('user_id', userId)
        .order('pinned_at', referencedTable: 'conversations', ascending: false)
        .order('last_message_at', referencedTable: 'conversations', ascending: false);

    final results = <Map<String, dynamic>>[];
    for (final row in data as List) {
      final conversation = row['conversations'] as Map<String, dynamic>?;
      final profile = row['profiles'] as Map<String, dynamic>?;
      if (conversation == null) continue;

      final lastMessageQuery = await _client
          .from('messages')
          .select('id, body, sender_id, kind, created_at, deleted_at')
          .eq('conversation_id', conversation['id'])
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final memberCount = await _client
          .from('conversation_members')
          .select('user_id')
          .eq('conversation_id', conversation['id']);

      final members = (memberCount as List)
          .map((m) => m['user_id'] as String)
          .toList();

      final unreadCount = await _client
          .from('messages')
          .select('id')
          .eq('conversation_id', conversation['id'])
          .gt('created_at', profile?['last_read_at'] ?? '1970-01-01T00:00:00Z')
          .neq('sender_id', userId)
          .isFilter('deleted_at', null)
          .count(CountOption.exact);

      results.add({
        ...conversation,
        'member_profile': profile,
        'last_message': lastMessageQuery,
        'member_ids': members,
        'unread_count': unreadCount.count,
      });
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> searchConversations(
    String userId,
    String query,
  ) async {
    final data = await _client
        .from('conversation_members')
        .select('''
          conversation_id,
          conversations (
            id, kind, title, description, avatar_path, created_by,
            last_message_at, pinned_at, muted_until, archived_at,
            created_at, deleted_at
          )
        ''')
        .eq('user_id', userId)
        .or('conversations.title.ilike.%$query%');

    return (data as List)
        .map((row) => row['conversations'] as Map<String, dynamic>)
        .where((c) => c.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>?> getConversation(String id) async {
    final data = await _client
        .from('conversations')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data;
  }

  Future<Map<String, dynamic>> createDirectConversation(
    String userId,
    String otherUserId,
  ) async {
    final response = await _client.rpc('create_direct_conversation', params: {
      'p_user_id': userId,
      'p_other_user_id': otherUserId,
    });
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createGroupConversation(
    String userId,
    String title,
    String description,
  ) async {
    final response = await _client.rpc('create_group_conversation', params: {
      'p_user_id': userId,
      'p_title': title,
      'p_description': description,
    });
    return response as Map<String, dynamic>;
  }

  Future<void> updateGroup(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await _client.from('conversations').update(updates).eq('id', id);
  }

  Future<void> addMembers(
    String conversationId,
    List<String> userIds,
  ) async {
    final rows = userIds
        .map((uid) => {
              'conversation_id': conversationId,
              'user_id': uid,
              'role': 'member',
              'joined_at': DateTime.now().toUtc().toIso8601String(),
            })
        .toList();
    await _client.from('conversation_members').insert(rows);
  }

  Future<void> removeMember(
    String conversationId,
    String userId,
  ) async {
    await _client
        .from('conversation_members')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  Future<void> promoteToAdmin(
    String conversationId,
    String userId,
  ) async {
    await _client
        .from('conversation_members')
        .update({'role': 'admin'})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  Future<void> demoteFromAdmin(
    String conversationId,
    String userId,
  ) async {
    await _client
        .from('conversation_members')
        .update({'role': 'member'})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  Future<void> blockUser(String userId, String blockedUserId) async {
    await _client
        .from('blocked_users')
        .upsert({
          'user_id': userId,
          'blocked_user_id': blockedUserId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
  }

  Future<void> unblockUser(String userId, String blockedUserId) async {
    await _client
        .from('blocked_users')
        .delete()
        .eq('user_id', userId)
        .eq('blocked_user_id', blockedUserId);
  }

  Future<void> pin(String conversationId) async {
    await _client
        .from('conversations')
        .update({'pinned_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }

  Future<void> unpin(String conversationId) async {
    await _client
        .from('conversations')
        .update({'pinned_at': null})
        .eq('id', conversationId);
  }

  Future<void> mute(String conversationId, {Duration? duration}) async {
    final mutedUntil = duration != null
        ? DateTime.now().toUtc().add(duration).toIso8601String()
        : null;
    await _client
        .from('conversations')
        .update({'muted_until': mutedUntil})
        .eq('id', conversationId);
  }

  Future<void> unmute(String conversationId) async {
    await _client
        .from('conversations')
        .update({'muted_until': null})
        .eq('id', conversationId);
  }

  Future<void> archive(String conversationId) async {
    await _client
        .from('conversations')
        .update({'archived_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }

  Future<void> unarchive(String conversationId) async {
    await _client
        .from('conversations')
        .update({'archived_at': null})
        .eq('id', conversationId);
  }

  Future<void> clear(String conversationId) async {
    await _client
        .from('messages')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('conversation_id', conversationId);
  }

  Future<void> delete(String conversationId) async {
    await _client
        .from('conversations')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }

  Stream<List<Map<String, dynamic>>> watchTypingUsers(
    String conversationId,
  ) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    final typingUsers = <String, Map<String, dynamic>>{};

    final channel = _client.channel('typing:$conversationId');

    channel.onBroadcast(
      event: 'typing',
      callback: (payload) {
        final userId = payload['userId'] as String?;
        final isTyping = payload['isTyping'] as bool? ?? false;
        if (userId == null) return;

        if (isTyping) {
          typingUsers[userId] = {
            'user_id': userId,
            'typing_at': DateTime.now().toIso8601String(),
          };
        } else {
          typingUsers.remove(userId);
        }
        controller.add(typingUsers.values.toList());
      },
    );

    channel.subscribe((status, error) {
      if (error != null) {
        controller.addError(error);
      }
    });

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  void sendTypingEvent(
    String conversationId,
    String userId,
    bool isTyping,
  ) {
    final channel = _client.channel('typing:$conversationId');
    channel.sendBroadcastMessage(
      event: 'typing',
      payload: {
        'userId': userId,
        'isTyping': isTyping,
      },
    );
    channel.subscribe();
  }

  Stream<Set<String>> watchPresence(List<String> userIds) {
    final controller = StreamController<Set<String>>();
    final onlineUsers = <String>{};

    final channel = _client.channel('presence:${userIds.join('-')}');

    channel
      ..onPresenceSync((_) {
        onlineUsers.clear();
        for (final state in channel.presenceState()) {
          for (final p in state.presences) {
            final uid = p.payload['user_id'] as String?;
            if (uid != null) onlineUsers.add(uid);
          }
        }
        controller.add(Set.from(onlineUsers));
      })
      ..onPresenceJoin((presence) {
        for (final p in presence.newPresences) {
          final uid = p.payload['user_id'] as String?;
          if (uid != null) onlineUsers.add(uid);
        }
        controller.add(Set.from(onlineUsers));
      })
      ..onPresenceLeave((presence) {
        for (final p in presence.leftPresences) {
          final uid = p.payload['user_id'] as String?;
          if (uid != null) onlineUsers.remove(uid);
        }
        controller.add(Set.from(onlineUsers));
      });

    channel.subscribe((status, error) {
      if (error != null) {
        controller.addError(error);
      }
    });

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }
}
