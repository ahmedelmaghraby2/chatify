import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMessageDatasource {
  SupabaseMessageDatasource(this._client);
  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> loadInitial(
    String conversationId,
  ) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> loadOlder(
    String conversationId,
    String before,
  ) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .lt('created_at', before)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> loadAround(
    String conversationId,
    String messageId,
  ) async {
    final target = await getMessage(messageId);
    if (target == null) return [];

    final targetTime = target['created_at'] as String;

    final before = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .lt('created_at', targetTime)
        .order('created_at', ascending: false)
        .limit(25);

    final after = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .gt('created_at', targetTime)
        .order('created_at', ascending: true)
        .limit(25);

    final messages = <Map<String, dynamic>>[
      ...(before as List).cast<Map<String, dynamic>>(),
      target,
      ...(after as List).cast<Map<String, dynamic>>(),
    ];

    messages.sort((a, b) =>
        (a['created_at'] as String).compareTo(b['created_at'] as String));

    return messages;
  }

  Future<Map<String, dynamic>> insertMessage(
    Map<String, dynamic> data,
  ) async {
    final result = await _client
        .from('messages')
        .insert(data)
        .select()
        .single();
    return result;
  }

  Future<void> updateMessage(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await _client.from('messages').update(updates).eq('id', id);
  }

  Future<void> deleteMessage(String id) async {
    await _client
        .from('messages')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> permanentDeleteMessage(String id) async {
    await _client.from('messages').delete().eq('id', id);
  }

  Stream<PostgresChangePayload> watchMessages(
    String conversationId,
  ) {
    final controller = StreamController<PostgresChangePayload>();

    final channel = _client.channel('messages:$conversationId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) {
        controller.add(payload);
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

  Future<List<Map<String, dynamic>>> searchMessages(
    String conversationId,
    String query,
  ) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .textSearch('body', query, type: TextSearchType.websearch)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getMessage(String id) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data;
  }

  Future<void> addReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    await _client.from('message_reactions').upsert({
      'message_id': messageId,
      'user_id': userId,
      'emoji': emoji,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> removeReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    await _client
        .from('message_reactions')
        .delete()
        .eq('message_id', messageId)
        .eq('user_id', userId)
        .eq('emoji', emoji);
  }

  Future<void> updateDeliveryState(
    String messageId,
    String status,
  ) async {
    await _client
        .from('messages')
        .update({'status': status})
        .eq('id', messageId);
  }

  Future<List<Map<String, dynamic>>> loadReactions(
    String messageId,
  ) async {
    final data = await _client
        .from('message_reactions')
        .select()
        .eq('message_id', messageId);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<int> getUnreadCount(
    String conversationId,
    String userId,
    String? lastReadMessageId,
  ) async {
    if (lastReadMessageId != null) {
      final lastRead = await getMessage(lastReadMessageId);
      if (lastRead != null) {
        final response = await _client
            .from('messages')
            .select('id')
            .eq('conversation_id', conversationId)
            .neq('sender_id', userId)
            .gt('created_at', lastRead['created_at'])
            .isFilter('deleted_at', null)
            .count(CountOption.exact);
        return response.count;
      }
    }

    final response = await _client
        .from('messages')
        .select('id')
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .isFilter('deleted_at', null)
        .count(CountOption.exact);
    return response.count;
  }
}
