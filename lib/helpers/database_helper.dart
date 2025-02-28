import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create chats table
        await db.execute('''
          CREATE TABLE chats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            model TEXT,
            created_at TEXT,
            last_modified TEXT
          )
        ''');

        // Create messages table linked to chats
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chat_id INTEGER,
            sender TEXT,
            message TEXT,
            timestamp TEXT,
            FOREIGN KEY(chat_id) REFERENCES chats(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Insert new chat
  Future<int> insertChat(String title, String model) async {
    final db = await database;
    return await db.insert('chats', {
      'title': title,
      'model': model,
      'created_at': DateTime.now().toIso8601String(),
      'last_modified': DateTime.now().toIso8601String(),
    });
  }

  // Get all chats
  Future<List<Map<String, dynamic>>> getChats() async {
    final db = await database;
    return await db.query('chats', orderBy: 'last_modified DESC');
  }

  // Insert message into a chat
  Future<int> insertMessage(int chatId, String sender, String message) async {
    final db = await database;
    int msgId = await db.insert('messages', {
      'chat_id': chatId,
      'sender': sender,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Update chat's last modified timestamp
    await db.update(
      'chats',
      {'last_modified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [chatId],
    );

    return msgId;
  }

  // Get messages for a specific chat
  Future<List<Map<String, dynamic>>> getMessages(int chatId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
  }

  // Update chat title
  Future<void> updateChatTitle(int chatId, String newTitle) async {
    final db = await database;
    await db.update(
      'chats',
      {'title': newTitle, 'last_modified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> clearChats() async {
    final db = await database;
    await db.delete('chats');
    await db.delete('messages');
  }
}
