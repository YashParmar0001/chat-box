import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/repositories/chat_repository.dart';
import 'package:chat_box/services/local_media_service.dart';
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

  int page = 1;

  final _messages = <MessageModel>[].obs;
  final _isLoadingMessages = true.obs;

  bool get isLoadingMessages => _isLoadingMessages.value;

  List<MessageModel> get messages => _messages;

  QueryDocumentSnapshot<Map<String, dynamic>>? start;

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
  final _isSendingVideoMessage = false.obs;
  final _isSendingImageMessage = false.obs;
  final _sendButtonEnabled = false.obs;

  bool get isSendingMessage => _isSendingMessage.value;

  bool get sendButtonEnabled => _sendButtonEnabled.value;

  bool get isSendingVideoMessage => _isSendingVideoMessage.value;

  bool get isSendingImageMessage => _isSendingImageMessage.value;

  final chatRepository = ChatRepository();

  final _firestore = FirebaseFirestore.instance;

  String get chatKey {
    final sortedEmails = [currentUserId, otherUserId]..sort();

    String chatKey = sortedEmails.join('#');

    return chatKey;
  }

  StreamSubscription? _typingStatusSubscription;
  StreamSubscription? _messagesSubscription;
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
      typingTimer = Timer(const Duration(seconds: 4), () {
        chatRepository.changeTypingStatus(chatKey, currentUserId, false);
      });
    });

    listenToTypingStatus();
    super.onInit();
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _typingStatusSubscription?.cancel();
    super.onClose();
  }

  void listenToTypingStatus() {
    _typingStatusSubscription =
        chatRepository.getTypingStatus(chatKey, otherUserId).listen(
      (isTyping) {
        _isTyping.value = isTyping;
      },
    );
  }

  Future<void> getMessages() async {
    _messages.value = await sqliteService.getMessages(chatKey: chatKey);
    dev.log('Local messages: $messages', name: 'LocalStorage');

    startListeningForMessages();
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

  void startListeningForMessages() {
    _isLoadingMessages.value = true;
    final ref =
        _firestore.collection('chats').doc(chatKey).collection('messages');

    var query = ref.orderBy('time', descending: true);

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

      if (snapshots.docs.isNotEmpty) start = snapshots.docs.last;

      var query = ref.orderBy('time');

      synchronizeWithLocalDB(snapshots.docs);

      if (start != null) query = query.startAtDocument(start!);

      // if (messages.isNotEmpty && snapshots.docs.isEmpty) {
      //   _isLoadingMessages.value = false;
      //   return;
      // }

      _messagesSubscription = query.snapshots().listen((event) async {
        for (var change in event.docChanges) {
          MessageModel message = MessageModel.fromMap(change.doc.data()!);

          if (change.type == DocumentChangeType.added) {
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

              sqliteService.storeMessage(message: message, chatKey: chatKey);

              // if (_messages.contains(message)) {
              //   final index = messages.indexWhere(
              //     (msg) => msg.timestamp == message.timestamp,
              //   );
              //   final oldMessage = messages[index];
              //
              //   // Check for media
              //   if (oldMessage.imageUrl != null &&
              //       oldMessage.localImagePath == null) {
              //     dev.log('Processing image path for message', name: 'Chat');
              //     oldMessage.localImagePath ??=
              //         await processLocalImagePath(oldMessage);
              //     if (oldMessage.localImagePath != null) {
              //       // Update UI
              //       if (index != -1) {
              //         _messages[index] = _messages[index].copyWith(
              //           localImagePath: oldMessage.localImagePath,
              //         );
              //       }
              //
              //       // Update local message
              //       sqliteService.updateMessage2(
              //         fields: ['local_image_uri'],
              //         values: [oldMessage.localImagePath],
              //         id: oldMessage.timestamp,
              //       );
              //     }
              //   } else if (oldMessage.videoUrl != null &&
              //       oldMessage.localVideoPath == null) {
              //     oldMessage.localVideoPath ??=
              //         await processLocalVideoPath(oldMessage);
              //     if (oldMessage.localVideoPath != null) {
              //       // Update UI
              //       if (index != -1) {
              //         _messages[index] = _messages[index].copyWith(
              //           localVideoPath: oldMessage.localVideoPath,
              //         );
              //       }
              //
              //       // Update local message
              //       sqliteService.updateMessage2(
              //         fields: ['local_video_uri'],
              //         values: [message.localVideoPath],
              //         id: message.timestamp,
              //       );
              //     }
              //   }
              // }
            }
          } else if (change.type == DocumentChangeType.modified) {
            dev.log('Message modified', name: 'Chat');

            final existingMessageIndex = messages.indexWhere(
              (msg) => msg.timestamp == message.timestamp,
            );

            if (existingMessageIndex != -1) {
              _messages[existingMessageIndex] =
                  _messages[existingMessageIndex].copyWith(
                text: message.text,
                isRead: message.isRead,
              );
            }

            sqliteService.updateMessage2(
              fields: ['content', 'is_read'],
              values: [message.text, message.isRead ? 1 : 0],
              id: message.timestamp,
            );
            // sqliteService.updateMessage3(message: messageModel);
          } else if (change.type == DocumentChangeType.removed) {
            dev.log('Message removed: ${message.text}', name: 'Chat');
            if (currentUserId != (change.doc.data()!['sender_id']).toString()) {
              _messages.removeWhere(
                (e) => e.timestamp.toString() == change.doc.id,
              );
              sqliteService.deleteMessage(messageId: int.parse(change.doc.id));
            }
          }
        }
      });
      _isLoadingMessages.value = false;
    });
  }

  Future<void> sendMessage({bool isMediaMessage = false}) async {
    _isSendingMessage.value = true;
    if (selectedVideo != null) {
      _isSendingVideoMessage.value = true;
    }
    if (selectedImage != null) {
      _isSendingImageMessage.value = true;
    }

    final otherUser = Get.find<ChatController>()
        .users
        .firstWhere((e) => e.email == otherUserId);

    // If user is blocked don't send the message
    if (otherUser.blockedUsers.contains(currentUserId)) {
      _isSendingMessage.value = false;
      return;
    }

    final isOnline = otherUser.isOnline;

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
      // if (_listeners.isEmpty) {
      //   startListeningForMessages(false);
      // }
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      Get.snackbar('Chat', 'Something went wrong while sending the message!');
    }

    if (isMediaMessage) {
      Get.back();
    }
    _isSendingMessage.value = false;
    _isSendingImageMessage.value = false;
    _isSendingVideoMessage.value = false;
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
    final localPath = await LocalMediaService.getLocalPhotoPath(
      chatKey: chatKey,
      messageId: message.timestamp,
    );
    if (localPath == null) {
      final path = await LocalMediaService.downloadAndCachePhoto(
        chatKey: chatKey,
        messageId: message.timestamp,
      );
      imagePath = path;
    } else {
      imagePath = localPath;
    }

    final index = messages.indexWhere(
      (msg) => msg.timestamp == message.timestamp,
    );

    // Update UI
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(localImagePath: imagePath);
    }

    sqliteService.updateMessage2(
      fields: ['local_image_uri'],
      values: [imagePath],
      id: message.timestamp,
    );

    return imagePath;
  }

  Future<String?> processLocalVideoPath(MessageModel message) async {
    String? videoPath;
    if (message.videoUrl != null) {
      final localPath = await LocalMediaService.getLocalVideoPath(
        chatKey: chatKey,
        messageId: message.timestamp,
      );
      if (localPath == null) {
        final path = await LocalMediaService.downloadAndCacheVideo(
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
      await sqliteService.updateMessage2(
        fields: ['content', 'is_read'],
        values: [message.text, message.isRead ? 1 : 0],
        id: message.timestamp,
      );
    }

    _messages.value = await sqliteService.getMessages(chatKey: chatKey);
  }
}
