import 'package:chat_box/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String chatKey,
    required MessageModel message,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(message.timestamp.toString())
        .set(message.toMap());
  }

  Future<void> deleteMessage({
    required String chatKey,
    required String id,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatKey)
        .collection('messages')
        .doc(id)
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
