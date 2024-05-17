import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/repositories/chat_repository.dart';
import 'package:chat_box/services/local_photo_service.dart';
import 'package:chat_box/services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrentChatController extends GetxController {
  CurrentChatController({
    required this.currentUserId,
    required this.otherUserId,
  });

  final SqliteService sqliteService = Get.find<SqliteService>();

  final _messageLimit = 10;
  final _atMaxLimit = false.obs;

  bool get atMaxLimit => _atMaxLimit.value;

  // int get _page => _listeners.length;
  int page = 1;

  final _messages = <MessageModel>[].obs;
  final _isLoadingMessages = true.obs;

  bool get isLoadingMessages => _isLoadingMessages.value;

  List<MessageModel> get messages => _messages;

  final _listeners = <StreamSubscription>[].obs;
  QueryDocumentSnapshot<Map<String, dynamic>>? start, end;

  final String currentUserId;
  final String otherUserId;

  final _isTyping = false.obs;

  bool get isTyping => _isTyping.value;

  final _selectedImage = Rx<File?>(null);

  final _selectedVideo = Rx<File?>(null);

  File? get selectedImage => _selectedImage.value;

  File? get selectedVideo => _selectedVideo.value;

  set selectedImage(File? file) {
    _selectedImage.value = file;
    if (file != null) {
      _selectedVideo.value = null;
    }
  }

  set selectedVideo(File? file) {
    _selectedVideo.value = file;
    if (file != null) {
      _selectedImage.value = null;
    }
  }

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

  StreamSubscription? typingStatusSubscription;
  Timer? typingTimer;

  @override
  void onInit() {
    getMessages();

    messageTextController.addListener(() {
      if (messageTextController.text.trim().isEmpty) {
        _sendButtonEnabled.value = false;
      } else {
        _sendButtonEnabled.value = true;
      }

      chatRepository.changeTypingStatus(chatKey, currentUserId, true);
      typingTimer?.cancel();
      typingTimer = Timer(const Duration(seconds: 1), () {
        chatRepository.changeTypingStatus(chatKey, currentUserId, false);
      });
    });

    listenToTypingStatus();

    ever(_isTyping, (isTyping) {
      dev.log('Typing: $isTyping', name: 'Typing');
    });
    super.onInit();
  }

  @override
  void onClose() {
    for (var element in _listeners) {
      element.cancel();
    }
    super.onClose();
  }

  void listenToTypingStatus() {
    typingStatusSubscription =
        chatRepository.getTypingStatus(chatKey, otherUserId).listen(
      (isTyping) {
        _isTyping.value = isTyping;
      },
    );
  }

  Future<void> getMessages() async {
    _messages.value = await sqliteService.getMessages(chatKey: chatKey);
    dev.log('Local messages: $messages', name: 'LocalStorage');

    startListeningForMessages(false);
  }

  Future<void> getMoreMessages() async {
    _isLoadingMessages.value = true;
    dev.log('Fetching more messages | Page: $page', name: 'Chat');
    final newMessages = await sqliteService.getMessages(
      chatKey: chatKey,
      page: page,
    );
    if (newMessages.isEmpty) {
      _atMaxLimit.value = true;
    }
    _messages.addAll(newMessages);
    page++;
    _isLoadingMessages.value = false;
    // startListeningForMessages(true);
  }

  void startListeningForMessages(bool fetchMore) {
    _isLoadingMessages.value = true;
    final ref =
        _firestore.collection('chats').doc(chatKey).collection('messages');

    var query = ref.orderBy('time', descending: true);

    if (fetchMore) query = query.startAfterDocument(start!);

    query.limit(_messageLimit).get().then((snapshots) async {
      dev.log(
        'Got snapshots: ${snapshots.docs.map((e) => e.data()['content']).toList()}',
        name: 'Chat',
      );
      if (snapshots.metadata.isFromCache) {
        dev.log('Snapshots are from cache', name: 'Chat');
        _isLoadingMessages.value = false;
        return;
      }
      if (fetchMore) end = start;
      if (snapshots.docs.isNotEmpty) start = snapshots.docs.last;

      var query = ref.orderBy('time');

      if (!fetchMore && snapshots.docs.isNotEmpty) {
        dev.log('Synchronizing messages with local database', name: 'Chat');
        await synchronizeWithLocalDB(snapshots.docs);
      }

      if (start != null) query = query.startAtDocument(start!);

      if (messages.isNotEmpty && snapshots.docs.isEmpty) {
        _isLoadingMessages.value = false;
        return;
      }

      if (fetchMore) query = query.endBeforeDocument(end!);

      final listener = query.snapshots().listen((event) async {
        for (var change in event.docChanges) {
          if (change.type == DocumentChangeType.added) {
            MessageModel message = MessageModel.fromMap(change.doc.data()!);
            if (message.senderId != currentUserId && !message.isRead) {
              chatRepository.changeMessageToRead(
                chatKey,
                message.timestamp.toString(),
              );
            }

            if (!_messages.contains(message)) {
              dev.log(
                'New message added: ${message.text}, ${message.localImagePath}',
                name: 'Chat',
              );
              _messages.insert(0, message);
              // _messages.value = Set<MessageModel>.from(_messages).toList();

              final imagePath = await processLocalImagePath(message);
              final videoPath = await processLocalVideoPath(message);

              final existingMessageIndex = messages.indexWhere(
                (msg) => msg.timestamp == message.timestamp,
              );

              message = messages[existingMessageIndex].copyWith(
                localImagePath: imagePath,
                localVideoPath: videoPath,
              );
              if (existingMessageIndex != -1) {
                _messages[existingMessageIndex] = message;
              }

              // Store message locally
              dev.log(
                'Storing message through doc changes: $message',
                name: 'Read',
              );
              sqliteService.storeMessage(message: message, chatKey: chatKey);

              if (message.localImagePath != null ||
                  message.localVideoPath != null) {
                final existingMessageIndex = messages.indexWhere(
                  (msg) => message.timestamp == msg.timestamp,
                );

                if (existingMessageIndex != -1) {
                  _messages[existingMessageIndex] = message;
                }
              }
            }
          } else if (change.type == DocumentChangeType.modified) {
            dev.log('Message modified', name: 'Chat');

            MessageModel messageModel =
                MessageModel.fromMap(change.doc.data()!);
            final existingMessageIndex = messages.indexWhere(
              (message) => message.timestamp == messageModel.timestamp,
            );

            if (existingMessageIndex != -1) {
              _messages[existingMessageIndex] = messageModel;
            } else {
              _messages.add(messageModel);
            }

            // sqliteService.updateMessage(message: messageModel);
            sqliteService.updateMessage3(message: messageModel);
          } else if (change.type == DocumentChangeType.removed) {
            // dev.log(
            //   'Message deleted by ${change.doc.data()!['sender_id']}',
            //   name: 'Chat',
            // );
            if (currentUserId != (change.doc.data()!['sender_id']).toString()) {
              // dev.log('Deleting other user message', name: 'LocalStorage');
              _messages.removeWhere(
                (e) => e.timestamp.toString() == change.doc.id,
              );
              sqliteService.deleteMessage(messageId: int.parse(change.doc.id));
            }
          }
        }
        // _messages.sort((a, b) => b.timestamp - a.timestamp);
        // _cachePhotosAndAssignMessages();
      });
      _listeners.add(listener);
      _isLoadingMessages.value = false;
    });
  }

  Future<void> sendMessage() async {
    _isSendingMessage.value = true;

    final isOnline = Get.find<ChatController>()
        .users
        .firstWhere((e) => e.email == otherUserId)
        .isOnline;

    final message = MessageModel(
      senderId: currentUserId,
      receiverId: otherUserId,
      text: messageTextController.text.trim(),
      time: DateTime.now(),
      isRead: otherUserId == currentUserId,
      isDelivered: isOnline,
    );

    try {
      await chatRepository.sendMessage(
        chatKey: chatKey,
        message: message,
        image: selectedImage,
        video: selectedVideo,
      );
      messageTextController.clear();
      if (_listeners.isEmpty) {
        startListeningForMessages(false);
      }
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      Get.snackbar('Chat', 'Something went wrong while sending the message!');
    }
    _isSendingMessage.value = false;
    selectedImage = null;
    selectedVideo = null;
  }

  Future<void> unSendMessage(MessageModel message) async {
    try {
      dev.log('Deleting this user message', name: 'Deletion');
      await sqliteService.deleteMessage(messageId: message.timestamp);
      _messages.removeWhere((e) => e.timestamp == message.timestamp);
      await chatRepository.deleteMessage(chatKey: chatKey, message: message);
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      Get.snackbar('Chat', 'Something went wrong while deleting the message!');
    }
  }

  Future<String?> processLocalImagePath(MessageModel message) async {
    String? imagePath;
    if (message.imageUrl != null) {
      final localPath = await LocalPhotoService.getLocalPhotoPath(
        chatKey: chatKey,
        messageId: message.timestamp,
      );
      if (localPath == null) {
        final path = await LocalPhotoService.downloadAndCachePhoto(
          chatKey: chatKey,
          messageId: message.timestamp,
        );
        imagePath = path;
      } else {
        imagePath = localPath;
      }
    }

    return imagePath;
  }

  Future<String?> processLocalVideoPath(MessageModel message) async {
    String? videoPath;
    if (message.videoUrl != null) {
      final localPath = await LocalPhotoService.getLocalVideoPath(
        chatKey: chatKey,
        messageId: message.timestamp,
      );
      if (localPath == null) {
        final path = await LocalPhotoService.downloadAndCacheVideo(
          chatKey: chatKey,
          messageId: message.timestamp,
        );
        videoPath = path;
      } else {
        videoPath = localPath;
      }
    }

    return videoPath;
  }

  Future<void> synchronizeWithLocalDB(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final localMessages = messages;
    final firestoreMessages =
        docs.map((e) => MessageModel.fromMap(e.data())).toList();

    final firestoreMessageIds =
        firestoreMessages.map((msg) => msg.timestamp).toSet();

    final messagesToDelete = localMessages
        .where((msg) => !firestoreMessageIds.contains(msg.timestamp))
        .toList();

    final messagesToAddOrUpdate = firestoreMessages
        .where((msg) => !localMessages
            .any((localMsg) => localMsg.timestamp == msg.timestamp))
        .toList();

    final messagesToUpdate = firestoreMessages
        .where(
          (msg) => localMessages.any(
            (localMsg) =>
                localMsg.timestamp == msg.timestamp && localMsg != msg,
          ),
        )
        .toList();

    for (final message in messagesToDelete) {
      await sqliteService.deleteMessage(messageId: message.timestamp);
    }

    for (final message in messagesToAddOrUpdate) {
      dev.log('Storing message through synchronization: $message',
          name: 'Read');
      await sqliteService.storeMessage(chatKey: chatKey, message: message);
    }

    for (final message in messagesToUpdate) {
      final localMessage = localMessages.firstWhere(
        (e) => e.timestamp == message.timestamp,
      );
      await sqliteService.updateMessage2(
        fields: ['local_image_uri', 'local_video_uri'],
        values: [localMessage.localImagePath, localMessage.localVideoPath],
        id: message.timestamp,
      );
      // await sqliteService.updateMessage(
      //   message: message.copyWith(
      //     localImagePath: localMessage.localImagePath,
      //     localVideoPath: localMessage.localVideoPath,
      //   ),
      // );
    }

    _messages.value = await sqliteService.getMessages(chatKey: chatKey);
  }
}
