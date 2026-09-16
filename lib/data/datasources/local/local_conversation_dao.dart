import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class LocalConversationDao {
  LocalConversationDao(this._db);
  final LocalDatabase _db;

  Future<void> saveConversations(
    List<Map<String, dynamic>> conversations,
  ) async {
    final database = await _db.database;
    final batch = database.batch();

    for (final conversation in conversations) {
      batch.insert(
        'conversations',
        {
          'id': conversation['id'],
          'kind': conversation['kind'],
          'title': conversation['title'],
          'description': conversation['description'],
          'avatar_path': conversation['avatar_path'],
          'created_by': conversation['created_by'],
          'last_message_at': conversation['last_message_at'],
          'pinned_at': conversation['pinned_at'],
          'muted_until': conversation['muted_until'],
          'archived_at': conversation['archived_at'],
          'created_at': conversation['created_at'],
          'deleted_at': conversation['deleted_at'],
          'unread_count': conversation['unread_count'] ?? 0,
          'cached_json': jsonEncode(conversation),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final database = await _db.database;
    final rows = await database.query(
      'conversations',
      orderBy: 'pinned_at DESC NULLS LAST, last_message_at DESC NULLS LAST',
    );
    return rows.map((row) {
      final cached = row['cached_json'] as String?;
      if (cached != null) {
        return jsonDecode(cached) as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(row)..remove('cached_json');
    }).toList();
  }

  Future<Map<String, dynamic>?> getConversation(String id) async {
    final database = await _db.database;
    final rows = await database.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final cached = row['cached_json'] as String?;
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
    return Map<String, dynamic>.from(row)..remove('cached_json');
  }

  Future<void> deleteConversation(String id) async {
    final database = await _db.database;
    await database.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUnreadCount(
    String conversationId,
    int count,
  ) async {
    final database = await _db.database;
    await database.update(
      'conversations',
      {'unread_count': count},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<void> clear() async {
    final database = await _db.database;
    await database.delete('conversations');
  }
}
