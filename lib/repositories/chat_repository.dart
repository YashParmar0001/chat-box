import 'dart:io';
import 'dart:developer' as dev;

import 'package:chat_box/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> sendMessage({
    required String chatKey,
    required MessageModel message,
    File? image,
  }) async {
    if (image != null) {
      final url = await uploadImage(
        chatKey: chatKey,
        image: image,
        id: message.timestamp.toString(),
      );
      if (url == null) {
        throw Exception('Cannot upload image!');
      } else {
        message = message.copyWith(imageUrl: url);
      }
    }

    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(message.timestamp.toString())
        .set(message.toMap());
  }

  Future<String?> uploadImage({
    required String chatKey,
    required File image,
    required id,
  }) async {
    try {
      await _storage.ref('images/$chatKey/$id').putFile(image);
      final url = await _storage.ref('images/$chatKey/$id').getDownloadURL();
      return url;
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      return null;
    }
  }

  Future<void> deleteMessage({
    required String chatKey,
    required MessageModel message,
  }) async {
    if (message.imageUrl != null) {
      await _storage.ref('images/$chatKey/${message.timestamp}').delete();
    }

    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(message.timestamp.toString())
        .delete();
  }

  Stream<List<MessageModel>> getMessages(String chatKey) {
    return _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((e) => MessageModel.fromMap(e.data())).toList();
    });
  }
}
