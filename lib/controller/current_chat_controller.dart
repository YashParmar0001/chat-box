import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrentChatController extends GetxController {
  CurrentChatController({
    required this.currentUserId,
    required this.otherUserId,
  });

  final _messageLimit = 10;

  final _messages = <MessageModel>[].obs;
  final _isLoadingMessages = true.obs;

  bool get isLoadingMessages => _isLoadingMessages.value;

  List<MessageModel> get messages => _messages;

  final _listeners = <StreamSubscription>[].obs;
  QueryDocumentSnapshot<Map<String, dynamic>>? start, end;

  final String currentUserId;
  final String otherUserId;

  final _selectedImage = Rx<File?>(null);

  File? get selectedImage => _selectedImage.value;

  set selectedImage(File? file) => _selectedImage.value = file;

  final messageTextController = TextEditingController();
  final _isSendingMessage = false.obs;
  final _sendButtonEnabled = false.obs;

  bool get isSendingMessage => _isSendingMessage.value;

  bool get sendButtonEnabled => _sendButtonEnabled.value;

  final chatRepository = ChatRepository();

  final _firestore = FirebaseFirestore.instance;

  String get chatKey {
    final sortedEmails = [currentUserId, otherUserId]..sort();

    String chatKey = sortedEmails.join('#');

    return chatKey;
  }

  @override
  void onInit() {
    getMessages();

    messageTextController.addListener(() {
      if (messageTextController.text.trim().isEmpty) {
        _sendButtonEnabled.value = false;
      } else {
        _sendButtonEnabled.value = true;
      }
    });

    ever(
      _listeners,
      (list) => dev.log('Listeners length: ${list.length}', name: 'Chat'),
    );
    super.onInit();
  }

  @override
  void onClose() {
    for (var element in _listeners) {
      element.cancel();
    }
    super.onClose();
  }

  void getMessages() {
    startListeningForMessages(false);
  }

  void getMoreMessages() {
    dev.log('Fetching more messages', name: 'Chat');
    startListeningForMessages(true);
  }

  void startListeningForMessages(bool fetchMore) {
    _isLoadingMessages.value = true;
    final ref =
        _firestore.collection('chats').doc(chatKey).collection('messages');

    var query = ref.orderBy('time', descending: true);

    if (fetchMore) query = query.startAfterDocument(start!);

    query.limit(_messageLimit).get().then((snapshots) {
      dev.log('Got snapshots: ${snapshots.docs}', name: 'Chat');
      if (fetchMore) end = start;
      if (snapshots.docs.isNotEmpty) start = snapshots.docs.last;

      var query = ref.orderBy('time');

      if (start != null) query = query.startAtDocument(start!);

      if (messages.isNotEmpty && snapshots.docs.isEmpty) {
        _isLoadingMessages.value = false;
        return;
      }

      if (fetchMore) query = query.endBeforeDocument(end!);

      final listener = query.snapshots().listen((event) {
        for (var change in event.docChanges) {
          if (change.type == DocumentChangeType.added) {
            dev.log('New message added', name: 'Chat');
            _messages.add(MessageModel.fromMap(change.doc.data()!));
          } else if (change.type == DocumentChangeType.modified) {
            dev.log('Message modified', name: 'Chat');
            final messageModel = MessageModel.fromMap(change.doc.data()!);
            final existingMessageIndex = messages.indexWhere(
              (message) =>
                  message.timestamp.toString() ==
                  messageModel.timestamp.toString(),
            );

            if (existingMessageIndex != -1) {
              // Replace the existing message with the new one
              _messages[existingMessageIndex] = messageModel;
            } else {
              // Add the new message to the list
              _messages.add(messageModel);
            }
          } else if (change.type == DocumentChangeType.removed) {
            dev.log('Message deleted', name: 'Chat');
            _messages.removeWhere(
              (e) => e.timestamp.toString() == change.doc.id,
            );
          }
        }
        _messages.sort((a, b) => b.timestamp - a.timestamp);
      });
      _listeners.add(listener);
      _isLoadingMessages.value = false;
    });
  }

  Future<void> sendMessage() async {
    _isSendingMessage.value = true;
    final message = MessageModel(
      senderId: currentUserId,
      receiverId: otherUserId,
      text: messageTextController.text.trim(),
      time: DateTime.now(),
    );

    try {
      await chatRepository.sendMessage(
        chatKey: chatKey,
        message: message,
        image: selectedImage,
      );
      messageTextController.clear();
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      Get.snackbar('Chat', 'Something went wrong while sending the message!');
    }
    selectedImage = null;
    _isSendingMessage.value = false;
  }

  Future<void> deleteMessage(MessageModel message) async {
    try {
      await chatRepository.deleteMessage(chatKey: chatKey, message: message);
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      Get.snackbar('Chat', 'Something went wrong while deleting the message!');
    }
  }
}
