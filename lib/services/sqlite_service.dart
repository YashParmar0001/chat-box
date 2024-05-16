import 'dart:developer' as dev;

import 'package:chat_box/model/message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  final _messageLimit = 10;

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'chatbox_database.db'),
      version: 1,
      onCreate: (db, version) {
        dev.log('Initializing local database', name: 'Database');
        db.execute(
          'create table messages ('
          'message_id INTEGER PRIMARY KEY, '
          'sender_id TEXT, '
          'receiver_id TEXT, '
          'chat_id TEXT, '
          'content TEXT, '
          'timestamp INTEGER, '
          'image_url TEXT NULL, '
          'local_image_uri TEXT NULL, '
          'video_url TEXT NULL, '
          'video_thumbnail_url TEXT NULL, '
          'local_video_uri TEXT NULL, '
          'is_read INTEGER, '
          'is_delivered INTEGER'
          ')',
        );
      },
    );
  }

  Future<List<MessageModel>> getMessages({
    required String chatKey,
    int page = 0,
  }) async {
    final db = await initializeDB();
    final offset = page * _messageLimit;
    dev.log('Fetching messages from index: $offset', name: 'LocalStorage');
    final response = await db.query(
      'messages',
      orderBy: 'timestamp desc',
      where: 'chat_id = ?',
      whereArgs: [chatKey],
      offset: offset,
      limit: _messageLimit,
    );
    dev.log('Local db messages: $response', name: 'Chat');
    return response.map((e) => MessageModel.fromMap(e)).toList();
  }

  Future<int> storeMessage({
    required MessageModel message,
    required String chatKey,
  }) async {
    final data = message.toMapTimestamp();
    data['chat_id'] = chatKey;
    data['message_id'] = message.timestamp;

    final db = await initializeDB();
    final response = await db.insert(
      'messages',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return response;
  }

  Future<int> updateMessage({
    required MessageModel message,
  }) async {
    final data = message.toMapTimestamp();

    final db = await initializeDB();
    final response = await db.update(
      'messages',
      data,
      where: 'message_id = ?',
      whereArgs: [message.timestamp],
    );
    return response;
  }

  Future<int> deleteMessage({required int messageId}) async {
    dev.log('Deleting message from local database', name: 'LocalDatabase');
    final db = await initializeDB();
    final response = await db.delete(
      'messages',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
    return response;
  }
}
