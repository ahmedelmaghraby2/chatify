import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class LocalMessageDao {
  LocalMessageDao(this._db);
  final LocalDatabase _db;

  Future<void> saveMessages(
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    final database = await _db.database;
    final batch = database.batch();

    for (final message in messages) {
      batch.insert(
        'messages',
        {
          'id': message['id'],
          'client_id': message['client_id'],
          'conversation_id': conversationId,
          'sender_id': message['sender_id'],
          'kind': message['kind'] ?? 'text',
          'body': message['body'],
          'reply_to_id': message['reply_to_id'],
          'media_url': message['media_url'],
          'edited_at': message['edited_at'],
          'deleted_at': message['deleted_at'],
          'created_at': message['created_at'],
          'status': message['status'] ?? 'sent',
          'cached_json': jsonEncode(message),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    int limit = 50,
    String? before,
  }) async {
    final database = await _db.database;

    if (before != null) {
      final rows = await database.query(
        'messages',
        where: 'conversation_id = ? AND created_at < ? AND deleted_at IS NULL',
        whereArgs: [conversationId, before],
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return _decodeRows(rows);
    }

    final rows = await database.query(
      'messages',
      where: 'conversation_id = ? AND deleted_at IS NULL',
      whereArgs: [conversationId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return _decodeRows(rows);
  }

  Future<Map<String, dynamic>?> getMessageById(String messageId) async {
    final database = await _db.database;
    final rows = await database.query(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _decodeRow(rows.first);
  }

  Future<List<Map<String, dynamic>>> getMessagesAround(
    String messageId,
  ) async {
    final target = await getMessageById(messageId);
    if (target == null) return [];

    final database = await _db.database;
    final targetTime = target['created_at'] as String;

    final before = await database.query(
      'messages',
      where: 'conversation_id = ? AND created_at < ? AND deleted_at IS NULL',
      whereArgs: [target['conversation_id'], targetTime],
      orderBy: 'created_at DESC',
      limit: 25,
    );

    final after = await database.query(
      'messages',
      where: 'conversation_id = ? AND created_at > ? AND deleted_at IS NULL',
      whereArgs: [target['conversation_id'], targetTime],
      orderBy: 'created_at ASC',
      limit: 25,
    );

    final messages = <Map<String, dynamic>>[
      ..._decodeRows(before).reversed,
      target,
      ..._decodeRows(after),
    ];

    return messages;
  }

  Future<void> updateMessageStatus(
    String messageId,
    String status,
  ) async {
    final database = await _db.database;
    await database.update(
      'messages',
      {'status': status},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final database = await _db.database;
    await database.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<int> savePendingOperation(Map<String, dynamic> operation) async {
    final database = await _db.database;
    return await database.insert('pending_operations', {
      'operation_type': operation['operation_type'],
      'entity_type': operation['entity_type'],
      'entity_id': operation['entity_id'],
      'payload': operation['payload'] is String
          ? operation['payload']
          : jsonEncode(operation['payload']),
      'created_at': operation['created_at'] ??
          DateTime.now().toUtc().toIso8601String(),
      'retry_count': operation['retry_count'] ?? 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final database = await _db.database;
    final rows = await database.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );
    return rows.map((row) {
      final payload = row['payload'] as String?;
      return {
        ...Map<String, dynamic>.from(row),
        'payload': payload != null ? jsonDecode(payload) : null,
      };
    }).toList();
  }

  Future<void> deletePendingOperation(int operationId) async {
    final database = await _db.database;
    await database.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  Future<void> incrementRetryCount(int operationId) async {
    final database = await _db.database;
    await database.rawUpdate(
      'UPDATE pending_operations SET retry_count = retry_count + 1 WHERE id = ?',
      [operationId],
    );
  }

  Future<void> clearConversation(String conversationId) async {
    final database = await _db.database;
    await database.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  List<Map<String, dynamic>> _decodeRows(List<Map<String, Object?>> rows) {
    return rows.map(_decodeRow).toList();
  }

  Map<String, dynamic> _decodeRow(Map<String, Object?> row) {
    final cached = row['cached_json'] as String?;
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
    return Map<String, dynamic>.from(row)..remove('cached_json');
  }
}
