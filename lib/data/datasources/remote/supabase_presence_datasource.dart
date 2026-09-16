import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePresenceDatasource {
  SupabasePresenceDatasource(this._client);
  final SupabaseClient _client;

  RealtimeChannel? _presenceChannel;

  Future<void> goOnline(String userId) async {
    await _ensureChannel(userId);
    await _presenceChannel!.track({
      'user_id': userId,
      'online_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'online',
    });
  }

  Future<void> goOffline(String userId) async {
    if (_presenceChannel != null) {
      await _presenceChannel!.untrack();
      _client.removeChannel(_presenceChannel!);
      _presenceChannel = null;
    }
    await _client.from('user_presence').upsert({
      'user_id': userId,
      'is_online': false,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Stream<Set<String>> watchOnlineUsers() {
    final controller = StreamController<Set<String>>();
    final onlineUsers = <String>{};

    final channel = _client.channel('global-presence');

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

  Future<void> updateLastSeen(String userId) async {
    await _client.from('user_presence').upsert({
      'user_id': userId,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _ensureChannel(String userId) async {
    if (_presenceChannel != null) return;

    _presenceChannel = _client.channel('presence:$userId');

    _presenceChannel!.onPresenceSync((presence) {
      final current = _presenceChannel!.presenceState();
      if (current.isEmpty) {
        _presenceChannel!.track({
          'user_id': userId,
          'online_at': DateTime.now().toUtc().toIso8601String(),
          'status': 'online',
        });
      }
    });

    _presenceChannel!.subscribe((status, error) {
      if (error != null) return;
      if (status == RealtimeSubscribeStatus.subscribed) {
        _presenceChannel!.track({
          'user_id': userId,
          'online_at': DateTime.now().toUtc().toIso8601String(),
          'status': 'online',
        });
      }
    });
  }
}
