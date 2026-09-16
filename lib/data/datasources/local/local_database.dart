import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chatify.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        title TEXT,
        description TEXT,
        avatar_path TEXT,
        created_by TEXT,
        last_message_at TEXT,
        pinned_at TEXT,
        muted_until TEXT,
        archived_at TEXT,
        created_at TEXT NOT NULL,
        deleted_at TEXT,
        unread_count INTEGER DEFAULT 0,
        cached_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        conversation_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        kind TEXT NOT NULL,
        body TEXT,
        reply_to_id TEXT,
        media_url TEXT,
        edited_at TEXT,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'sending',
        cached_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        payload TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_messages_conversation_created ON messages (conversation_id, created_at)',
    );

    await db.execute(
      'CREATE INDEX idx_pending_operations_created ON pending_operations (created_at)',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
