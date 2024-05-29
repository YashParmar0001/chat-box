import 'dart:developer' as dev;

import 'package:chat_box/model/group_message_model.dart';
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
        db.execute(
          'create table group_messages ('
          'message_id INTEGER PRIMARY KEY, '
          'sender_id TEXT, '
          'group_id TEXT, '
          'content TEXT, '
          'timestamp INTEGER, '
          'image_url TEXT NULL, '
          'local_image_path TEXT NULL, '
          'video_url TEXT NULL, '
          'video_thumbnail_url TEXT NULL, '
          'local_video_path TEXT NULL, '
          'read_by TEXT NULL'
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

  Future<List<GroupMessageModel>> getGroupMessages({
    required String groupKey,
    int page = 0,
  }) async {
    dev.log('Fetching messages for Page: $page', name: 'LocalStorage');
    final db = await initializeDB();
    final offset = page * _messageLimit;
    final response = await db.query(
      'group_messages',
      orderBy: 'timestamp desc',
      where: 'group_id = ?',
      whereArgs: [groupKey],
      offset: offset,
      limit: _messageLimit,
    );
    return response.map((e) {
      final data = Map<String, dynamic>.from(e);
      if (e['read_by'] == null) {
        data['read_by'] = [];
      } else {
        data['read_by'] = e['read_by'].toString().split(',');
      }
      return GroupMessageModel.fromMap(data);
    }).toList();
  }

  Future<int> storeMessage({
    required MessageModel message,
    required String chatKey,
  }) async {
    // dev.log('Storing message: $message');
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

  Future<int> storeGroupMessage({
    required GroupMessageModel message,
    required String groupKey,
  }) async {
    final data = message.toMapTimestamp();
    data['message_id'] = message.timestamp;

    final db = await initializeDB();
    final response = await db.insert(
      'group_messages',
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

  Future<int> updateGroupMessage({required GroupMessageModel message}) async {
    final data = message.toMapTimestamp();

    final db = await initializeDB();
    final response = await db.update(
      'group_messages',
      data,
      where: 'message_id = ?',
      whereArgs: [message.timestamp],
    );
    return response;
  }

  Future<int> updateGroupMessage2({
    required List<String> fields,
    required List<dynamic> values,
    required int id,
  }) async {
    final data = <String, dynamic>{};
    for (int i = 0; i < fields.length; i++) {
      data.addAll({fields[i]: values[i]});
    }
    final db = await initializeDB();
    final response = await db.update(
      'group_messages',
      data,
      where: 'message_id = ?',
      whereArgs: [id],
    );
    return response;
  }

  Future<int> updateMessage2({
    required List<String> fields,
    required List<dynamic> values,
    required int id,
  }) async {
    final data = <String, dynamic>{};
    for (int i = 0; i < fields.length; i++) {
      data.addAll({fields[i]: values[i]});
    }
    final db = await initializeDB();
    final response = await db.update(
      'messages',
      data,
      where: 'message_id = ?',
      whereArgs: [id],
    );
    return response;
  }

  Future<int> updateMessage3({required MessageModel message}) async {
    final data = message.toMapLocal();

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

  Future<int> deleteGroupMessage({required int messageId}) async {
    final db = await initializeDB();
    final response = await db.delete(
      'group_messages',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
    return response;
  }
}
