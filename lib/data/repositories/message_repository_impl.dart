import 'dart:async';

import '../../core/errors/failures.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/reaction.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/local/local_message_dao.dart';
import '../datasources/remote/supabase_auth_datasource.dart';
import '../datasources/remote/supabase_message_datasource.dart';
import '../models/dto/attachment_dto.dart';
import '../models/dto/message_dto.dart';
import '../models/dto/reaction_dto.dart';
import '../models/mappers/message_mapper.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl({
    required SupabaseMessageDatasource datasource,
    required LocalMessageDao localDao,
    required SupabaseAuthDatasource authDatasource,
  })  : _datasource = datasource,
        _localDao = localDao,
        _authDatasource = authDatasource;

  final SupabaseMessageDatasource _datasource;
  final LocalMessageDao _localDao;
  final SupabaseAuthDatasource _authDatasource;

  final _controllers = <String, StreamController<List<Message>>>{};
  final _subscriptions = <String, StreamSubscription<dynamic>>{};
  final _messages = <String, List<Message>>{};

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final controller = _controllers.putIfAbsent(
      conversationId,
      () => StreamController<List<Message>>.broadcast(),
    );
    unawaited(_emitLocal(conversationId));
    _subscribeRealtime(conversationId);
    return controller.stream;
  }

  @override
  Future<List<Message>> loadInitial(String conversationId) async {
    try {
      final rows = await _datasource.loadInitial(conversationId);
      await _localDao.saveMessages(conversationId, rows);
    } catch (e) {
      final cached = await _readLocal(conversationId);
      if (cached.isNotEmpty) return cached;
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
    return _mergeLocal(conversationId);
  }

  @override
  Future<List<Message>> loadOlder(
    String conversationId, {
    DateTime? before,
  }) async {
    final beforeIso = (before ?? DateTime.now()).toUtc().toIso8601String();
    List<Map<String, dynamic>> rows;
    try {
      rows = await _datasource.loadOlder(conversationId, beforeIso);
      await _localDao.saveMessages(conversationId, rows);
    } catch (e) {
      final local = await _localDao.getMessages(
        conversationId,
        before: beforeIso,
      );
      if (local.isNotEmpty) {
        return local.map(_mapToMessage).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
      if (e is Failure) rethrow;
      throw _mapError(e);
    }

    final older = rows.map(_mapToMessage).toList();
    final existing = _messages[conversationId] ?? const <Message>[];
    final existingIds = existing.map((m) => m.id).toSet();
    final merged = [
      ...existing,
      ...older.where((m) => !existingIds.contains(m.id)),
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _messages[conversationId] = merged;
    _emit(conversationId, merged);
    return older;
  }

  @override
  Future<List<Message>> loadAround(
    String conversationId,
    String messageId,
  ) async {
    try {
      final rows = await _datasource.loadAround(conversationId, messageId);
      await _localDao.saveMessages(conversationId, rows);
      return rows.map(_mapToMessage).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      try {
        final rows = await _localDao.getMessagesAround(messageId);
        return rows.map(_mapToMessage).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } catch (_) {
        if (e is Failure) rethrow;
        throw _mapError(e);
      }
    }
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    required MessageKind kind,
    String? replyToId,
    List<Attachment>? attachments,
  }) async {
    final userId = _requireUserId();
    final clientId = IdGenerator.generateClientId();
    final createdAt = DateTime.now();

    final optimistic = Message(
      id: clientId,
      clientId: clientId,
      conversationId: conversationId,
      senderId: userId,
      kind: kind,
      body: body,
      replyToId: replyToId,
      createdAt: createdAt,
      status: MessageStatus.pending,
      attachments: attachments ?? const [],
    );

    final current = _messages[conversationId] ?? await _readLocal(conversationId);
    final optimisticList = [...current, optimistic]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _messages[conversationId] = optimisticList;
    _emit(conversationId, optimisticList);

    int? pendingOperationId;
    try {
      await _localDao.saveMessages(conversationId, [_toMap(optimistic)]);
      pendingOperationId = await _localDao.savePendingOperation({
        'operation_type': 'send_message',
        'entity_type': 'message',
        'entity_id': clientId,
        'created_at': createdAt.toUtc().toIso8601String(),
        'payload': {
          'client_id': clientId,
          'conversation_id': conversationId,
          'sender_id': userId,
          'kind': _kindToString(kind),
          'body': body,
          if (replyToId != null) 'reply_to_id': replyToId,
          'created_at': createdAt.toUtc().toIso8601String(),
        },
      });
    } catch (_) {}

    try {
      final row = await _datasource.insertMessage({
        'client_id': clientId,
        'conversation_id': conversationId,
        'sender_id': userId,
        'kind': _kindToString(kind),
        'body': body,
        if (replyToId != null) 'reply_to_id': replyToId,
        'created_at': createdAt.toUtc().toIso8601String(),
      });

      final sent = _mapToMessage(row).copyWith(status: MessageStatus.sent);

      try {
        await _localDao.saveMessages(conversationId, [_toMap(sent)]);
        await _localDao.deleteMessage(clientId);
        if (pendingOperationId != null) {
          await _localDao.deletePendingOperation(pendingOperationId);
        }
      } catch (_) {}

      final list = _messages[conversationId] ?? const <Message>[];
      final updated = [...list.where((m) => m.id != clientId), sent]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _messages[conversationId] = updated;
      _emit(conversationId, updated);

      return sent;
    } catch (e) {
      final failed = optimistic.copyWith(status: MessageStatus.failed);
      try {
        await _localDao.saveMessages(conversationId, [_toMap(failed)]);
      } catch (_) {}
      final list = _messages[conversationId] ?? current;
      final updated = [...list.where((m) => m.id != clientId), failed]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _messages[conversationId] = updated;
      _emit(conversationId, updated);
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<Message> editMessage(String messageId, String body) async {
    final editedAt = DateTime.now();
    try {
      await _datasource.updateMessage(messageId, {
        'body': body,
        'edited_at': editedAt.toUtc().toIso8601String(),
      });
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }

    final row = await _localDao.getMessageById(messageId);
    if (row != null) {
      final updated =
          _mapToMessage(row).copyWith(body: () => body, editedAt: () => editedAt);
      await _localDao.saveMessages(updated.conversationId, [_toMap(updated)]);
      _replaceInMemory(updated.conversationId, updated, messageId);
      return updated;
    }

    try {
      final remote = await _datasource.getMessage(messageId);
      if (remote != null) {
        return _mapToMessage(remote)
            .copyWith(body: () => body, editedAt: () => editedAt);
      }
    } catch (_) {}

    throw const UnknownFailure(message: 'Message not found for edit');
  }

  @override
  Future<void> deleteForMe(String messageId) async {
    try {
      final row = await _localDao.getMessageById(messageId);
      await _localDao.deleteMessage(messageId);
      final conversationId = row?['conversation_id'] as String?;
      if (conversationId != null) {
        _removeFromMemory(conversationId, messageId);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteForEveryone(String messageId) async {
    try {
      await _datasource.deleteMessage(messageId);
      final row = await _localDao.getMessageById(messageId);
      if (row != null) {
        final deleted = _mapToMessage(row)
            .copyWith(deletedAt: () => DateTime.now());
        await _localDao.saveMessages(deleted.conversationId, [_toMap(deleted)]);
        _removeFromMemory(deleted.conversationId, messageId);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    final userId = _requireUserId();
    try {
      await _datasource.addReaction(messageId, userId, emoji);
      final row = await _localDao.getMessageById(messageId);
      if (row != null) {
        final message = _mapToMessage(row);
        final updated = message.copyWith(reactions: [
          ...message.reactions
              .where((r) => !(r.userId == userId && r.emoji == emoji)),
          Reaction(
            messageId: messageId,
            userId: userId,
            emoji: emoji,
            createdAt: DateTime.now(),
          ),
        ]);
        await _localDao.saveMessages(message.conversationId, [_toMap(updated)]);
        _replaceInMemory(message.conversationId, updated, messageId);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    final userId = _requireUserId();
    try {
      await _datasource.removeReaction(messageId, userId, emoji);
      final row = await _localDao.getMessageById(messageId);
      if (row != null) {
        final message = _mapToMessage(row);
        final updated = message.copyWith(
          reactions: message.reactions
              .where((r) => !(r.userId == userId && r.emoji == emoji))
              .toList(),
        );
        await _localDao.saveMessages(message.conversationId, [_toMap(updated)]);
        _replaceInMemory(message.conversationId, updated, messageId);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> markAsDelivered(String conversationId, String messageId) async {
    try {
      await _datasource.updateDeliveryState(messageId, 'delivered');
      await _updateLocalStatus(messageId, MessageStatus.delivered);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<void> markAsSeen(String conversationId, String messageId) async {
    try {
      await _datasource.updateDeliveryState(messageId, 'seen');
      await _updateLocalStatus(messageId, MessageStatus.seen);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<List<Message>> searchMessages(
    String conversationId,
    String query,
  ) async {
    try {
      final rows = await _datasource.searchMessages(conversationId, query);
      return rows.map(_mapToMessage).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  @override
  Future<Message?> getMessage(String messageId) async {
    try {
      final row = await _localDao.getMessageById(messageId);
      if (row != null) return _mapToMessage(row);
    } catch (_) {}

    try {
      final row = await _datasource.getMessage(messageId);
      if (row == null) return null;
      return _mapToMessage(row);
    } catch (e) {
      if (e is Failure) rethrow;
      throw _mapError(e);
    }
  }

  void _subscribeRealtime(String conversationId) {
    if (_subscriptions.containsKey(conversationId)) return;
    final subscription = _datasource.watchMessages(conversationId).listen(
          (_) => unawaited(_refresh(conversationId)),
          onError: (Object e) {
            final controller = _controllers[conversationId];
            if (controller != null && !controller.isClosed) {
              controller.addError(_mapError(e));
            }
          },
        );
    _subscriptions[conversationId] = subscription;
    final controller = _controllers[conversationId];
    if (controller != null) {
      controller.onCancel = () {
        subscription.cancel();
        _subscriptions.remove(conversationId);
        _controllers.remove(conversationId);
      };
    }
  }

  Future<void> _refresh(String conversationId) async {
    try {
      final rows = await _datasource.loadInitial(conversationId);
      await _localDao.saveMessages(conversationId, rows);

      final remoteMessages = rows.map(_mapToMessage).toList();
      final remoteIds = remoteMessages.map((m) => m.id).toSet();
      final current = _messages[conversationId] ?? const <Message>[];

      final merged = <Message>[
        ...remoteMessages,
        ...current.where(
          (m) => !remoteIds.contains(m.id) && (m.isPending || m.isFailed),
        ),
      ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _messages[conversationId] = merged;
      _emit(conversationId, merged);
    } catch (_) {}
  }

  Future<void> _emitLocal(String conversationId) async {
    final messages = await _readLocal(conversationId);
    if (messages.isEmpty) return;
    _messages[conversationId] = messages;
    _emit(conversationId, messages);
  }

  Future<List<Message>> _readLocal(String conversationId) async {
    try {
      final rows = await _localDao.getMessages(conversationId);
      return rows.map(_mapToMessage).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<List<Message>> _mergeLocal(String conversationId) async {
    final merged = await _readLocal(conversationId);
    _messages[conversationId] = merged;
    _emit(conversationId, merged);
    return merged;
  }

  Future<void> _updateLocalStatus(
    String messageId,
    MessageStatus status,
  ) async {
    final row = await _localDao.getMessageById(messageId);
    if (row == null) return;
    final updated = _mapToMessage(row).copyWith(status: status);
    await _localDao.saveMessages(updated.conversationId, [_toMap(updated)]);
    _replaceInMemory(updated.conversationId, updated, messageId);
  }

  void _replaceInMemory(
    String conversationId,
    Message message,
    String messageId,
  ) {
    final list = _messages[conversationId];
    if (list == null) return;
    final updated = [
      for (final m in list) m.id == messageId ? message : m,
    ];
    _messages[conversationId] = updated;
    _emit(conversationId, updated);
  }

  void _removeFromMemory(String conversationId, String messageId) {
    final list = _messages[conversationId];
    if (list == null) return;
    final updated = list.where((m) => m.id != messageId).toList();
    _messages[conversationId] = updated;
    _emit(conversationId, updated);
  }

  void _emit(String conversationId, List<Message> messages) {
    final controller = _controllers[conversationId];
    if (controller != null && !controller.isClosed) {
      controller.add(messages);
    }
  }

  String _requireUserId() {
    final userId = _authDatasource.currentAuthUser?.id;
    if (userId == null) {
      throw const AuthFailure(message: 'User is not authenticated');
    }
    return userId;
  }

  Message _mapToMessage(Map<String, dynamic> row) =>
      MessageDto.fromMap(row).toEntity();

  Map<String, dynamic> _toMap(Message message) {
    return {
      'id': message.id,
      'client_id': message.clientId,
      'conversation_id': message.conversationId,
      'sender_id': message.senderId,
      'kind': _kindToString(message.kind),
      'body': message.body,
      'reply_to_id': message.replyToId,
      'media_url': null,
      'edited_at': message.editedAt?.toUtc().toIso8601String(),
      'deleted_at': message.deletedAt?.toUtc().toIso8601String(),
      'created_at': message.createdAt.toUtc().toIso8601String(),
      'status': _statusToString(message.status),
      'reactions': message.reactions
          .map(
            (r) => ReactionDto(
              messageId: r.messageId,
              userId: r.userId,
              emoji: r.emoji,
              createdAt: r.createdAt,
            ).toMap(),
          )
          .toList(),
      'attachments': message.attachments
          .map(
            (a) => AttachmentDto(
              id: a.id,
              messageId: a.messageId,
              bucket: a.bucket,
              path: a.path,
              mimeType: a.mimeType,
              sizeBytes: a.sizeBytes,
              durationMs: a.durationMs,
              width: a.width,
              height: a.height,
            ).toMap(),
          )
          .toList(),
    };
  }

  String _kindToString(MessageKind kind) {
    switch (kind) {
      case MessageKind.image:
        return 'image';
      case MessageKind.video:
        return 'video';
      case MessageKind.document:
        return 'document';
      case MessageKind.voice:
        return 'voice';
      case MessageKind.system:
        return 'system';
      case MessageKind.text:
        return 'text';
    }
  }

  String _statusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return 'pending';
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.seen:
        return 'seen';
      case MessageStatus.failed:
        return 'failed';
      case MessageStatus.retrying:
        return 'retrying';
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