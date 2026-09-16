import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCallDatasource {
  SupabaseCallDatasource(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> initiateCall(
    String conversationId,
    String initiatorId,
    String kind,
  ) async {
    final result = await _client
        .from('calls')
        .insert({
          'conversation_id': conversationId,
          'initiator_id': initiatorId,
          'kind': kind,
          'status': 'ringing',
          'started_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();
    return result;
  }

  Future<void> acceptCall(String callId) async {
    await _client
        .from('calls')
        .update({
          'status': 'active',
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callId);
  }

  Future<void> rejectCall(String callId) async {
    await _client
        .from('calls')
        .update({
          'status': 'rejected',
          'ended_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callId);
  }

  Future<void> endCall(String callId) async {
    await _client
        .from('calls')
        .update({
          'status': 'ended',
          'ended_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callId);
  }

  Stream<Map<String, dynamic>> watchActiveCall(String callId) {
    final controller = StreamController<Map<String, dynamic>>();

    final channel = _client.channel('call:$callId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'calls',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: callId,
      ),
      callback: (payload) {
        final record = payload.newRecord;
        if (record.isNotEmpty) {
          controller.add(record);
        }
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

  Stream<List<Map<String, dynamic>>> watchIncomingCalls(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    final channel = _client.channel('incoming-calls:$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'calls',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'status',
        value: 'ringing',
      ),
      callback: (payload) async {
        final call = payload.newRecord;
        if (call.isEmpty) return;

        final participantCheck = await _client
            .from('call_participants')
            .select('user_id')
            .eq('call_id', call['id'])
            .eq('user_id', userId)
            .maybeSingle();

        if (participantCheck != null) {
          final existing = <Map<String, dynamic>>[];
          controller.add([...existing, call]);
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'calls',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'status',
        value: 'ended',
      ),
      callback: (payload) {
        final call = payload.newRecord;
        if (call.isEmpty) return;
        controller.add([]);
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

  Future<void> updateSignaling(
    String callId,
    Map<String, dynamic> data,
  ) async {
    await _client
        .from('calls')
        .update({'signaling': data})
        .eq('id', callId);
  }

  Future<void> addIceCandidate(
    String callId,
    Map<String, dynamic> candidate,
  ) async {
    final row = await _client
        .from('calls')
        .select('signaling')
        .eq('id', callId)
        .maybeSingle();

    final signaling =
        (row?['signaling'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final candidates = (signaling['ice_candidates'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];

    await _client.from('calls').update({
      'signaling': {
        ...signaling,
        'ice_candidates': [...candidates, candidate],
      },
    }).eq('id', callId);
  }

  Future<void> addParticipant(
    String callId,
    String userId,
  ) async {
    await _client.from('call_participants').upsert({
      'call_id': callId,
      'user_id': userId,
      'joined_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> removeParticipant(
    String callId,
    String userId,
  ) async {
    await _client
        .from('call_participants')
        .delete()
        .eq('call_id', callId)
        .eq('user_id', userId);
  }
}
