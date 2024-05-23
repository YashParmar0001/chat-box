import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:chat_box/model/group_message_model.dart';
import 'package:chat_box/model/group_model.dart';
import 'package:chat_box/model/group_typing_status.dart';
import 'package:chat_box/repositories/group_repository.dart';
import 'package:chat_box/services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../model/user_model.dart';
import 'chat_controller.dart';

class CurrentGroupController extends GetxController {
  CurrentGroupController({required this.groupId, required this.currentUserId});

  final String groupId;
  final String currentUserId;

  final _group = Rx<Group?>(null);

  Group? get group => _group.value;

  final _messages = <GroupMessageModel>[].obs;
  final _typingStatuses = <GroupTypingStatus>[].obs;

  List<GroupMessageModel> get messages => _messages;

  List<GroupTypingStatus> get typingStatuses => _typingStatuses;

  final _messageLimit = 10;
  final _atMaxLimit = false.obs;

  bool get atMaxLimit => _atMaxLimit.value;

  int page = 1;

  final _isFetchingGroupDetails = true.obs;

  final _isLoadingMessages = true.obs;

  bool get isLoadingMessages => _isLoadingMessages.value;

  bool get isFetchingGroupDetails => _isFetchingGroupDetails.value;

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

  final _groupRepository = GroupRepository();
  final _sqliteService = SqliteService();
  final _firestore = FirebaseFirestore.instance;

  QueryDocumentSnapshot<Map<String, dynamic>>? start;

  StreamSubscription? _groupSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingStatusSubscription;
  Timer? typingTimer;

  @override
  void onInit() {
    messageTextController.addListener(() {
      if (messageTextController.text.trim().isEmpty) {
        _sendButtonEnabled.value = false;
      } else {
        _sendButtonEnabled.value = true;
      }

      _groupRepository.changeTypingStatus(groupId, currentUserId, true);
      typingTimer?.cancel();
      typingTimer = Timer(const Duration(seconds: 4), () {
        _groupRepository.changeTypingStatus(groupId, currentUserId, false);
      });
    });

    _groupSubscription = _groupRepository.getGroup(groupId).listen((group) {
      _group.value = group;
      _isFetchingGroupDetails.value = false;
    });
    getMessages();
    listenToTypingStatus();
    super.onInit();
  }

  @override
  void onClose() {
    _groupSubscription?.cancel();
    _messagesSubscription?.cancel();
    _typingStatusSubscription?.cancel();
    super.onClose();
  }

  void listenToTypingStatus() {
    _typingStatusSubscription =
        _groupRepository.getTypingStatus(groupId).listen(
      (event) {
        _typingStatuses.value = event;
      },
    );
  }

  Future<void> exitGroup(String userId) async {
    try {
      await _groupRepository.exitGroup(groupId: groupId, userId: userId);
      Get.back();
      Get.back();
      Get.snackbar('Group', 'Exited the group!');
    } catch (e) {
      Get.snackbar('Group', 'Something went wrong!');
    }
  }

  List<UserModel> getGroupMembers() {
    if (group == null) {
      return const [];
    } else {
      final users = Get.find<ChatController>().users;
      dev.log('Users: ${users.map((e) => e.name).toList()}', name: 'Group');
      dev.log('Group members: ${group!.memberIds}', name: 'Group');
      final members =
          users.where((e) => group!.memberIds.contains(e.email)).toList();
      dev.log('Group members: ${members.map((e) => e.name).toList()}', name: 'Group');
      final admin = members.firstWhere(
        (e) => e.email == group!.createdByUserId,
      );
      members.remove(admin);
      members.insert(0, admin);

      return members;
    }
  }

  Future<void> getMessages() async {
    // _isLoadingMessages.value = true;
    // _messagesSubscription =
    //     _groupRepository.getGroupMessages(groupId: groupId).listen(
    //   (messages) {
    //     _messages.value = messages;
    //     _isLoadingMessages.value = false;
    //   },
    // );
    _messages.value = await _sqliteService.getGroupMessages(groupKey: groupId);
    dev.log('Local db messages: $messages', name: 'Group');

    startListeningForMessages();
  }

  Future<void> getMoreMessages() async {
    _isLoadingMessages.value = true;
    final newMessages = await _sqliteService.getGroupMessages(
      groupKey: groupId,
      page: page,
    );
    if (newMessages.isEmpty) {
      _atMaxLimit.value = true;
    }
    _messages.addAll(newMessages);
    page++;
    _isLoadingMessages.value = false;
  }

  void startListeningForMessages() {
    _isLoadingMessages.value = true;
    final ref =
        _firestore.collection('groups').doc(groupId).collection('messages');

    var query = ref.orderBy('time', descending: true);

    query.limit(_messageLimit).get().then((snapshot) async {
      if (snapshot.metadata.isFromCache) {
        _isLoadingMessages.value = false;
        return;
      }

      var query = ref.orderBy('time');

      if (snapshot.docs.isNotEmpty) {
        start = snapshot.docs.last;
      }
      synchronizeWithLocalDB(snapshot.docs);

      // if (messages.isNotEmpty && snapshot.docs.isEmpty) {
      //   _isLoadingMessages.value = false;
      //   return;
      // }

      if (start != null) query = query.startAfterDocument(start!);

      _messagesSubscription = query.snapshots().listen((event) async {
        for (var change in event.docChanges) {
          if (change.type == DocumentChangeType.added) {
            GroupMessageModel message = GroupMessageModel.fromMap(
              change.doc.data()!,
            );

            if (!messages.contains(message)) {
              _messages.insert(0, message);

              _sqliteService.storeGroupMessage(
                message: message,
                groupKey: groupId,
              );
            }
          } else if (change.type == DocumentChangeType.modified) {
            GroupMessageModel message = GroupMessageModel.fromMap(
              change.doc.data()!,
            );
            final existingMessageIndex = messages.indexWhere(
              (msg) => msg.timestamp == message.timestamp,
            );

            if (existingMessageIndex != -1) {
              _messages[existingMessageIndex] = message;
            }

            _sqliteService.updateGroupMessage(message: message);
          } else if (change.type == DocumentChangeType.removed) {
            dev.log('Message removed', name: 'Group');
            if (currentUserId != (change.doc.data()!['sender_id']).toString()) {
              _messages.removeWhere(
                (e) => e.timestamp.toString() == change.doc.id,
              );
              _sqliteService.deleteGroupMessage(
                messageId: int.parse(change.doc.id),
              );
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

    final message = GroupMessageModel(
      senderId: currentUserId,
      groupId: groupId,
      text: messageTextController.text.trim(),
      time: DateTime.now(),
    );

    try {
      await _groupRepository.sendMessage(
        groupId: groupId,
        message: message,
        image: selectedImage,
        video: selectedVideo,
      );
      messageTextController.clear();
    } catch (e) {
      dev.log('Got error: $e', name: 'Chat');
      Get.snackbar('Chat', 'Something went wrong while sending the message!');
    }

    if (isMediaMessage) {
      Get.back();
    }
    _isSendingMessage.value = false;
    _isSendingVideoMessage.value = false;
    _isSendingImageMessage.value = false;
    selectedImage = null;
    selectedVideo = null;
  }

  Future<void> unSendMessage(GroupMessageModel message) async {
    try {
      dev.log('Deleting this user message', name: 'Deletion');
      await _sqliteService.deleteGroupMessage(messageId: message.timestamp);
      _messages.removeWhere((e) => e.timestamp == message.timestamp);
      await _groupRepository.deleteMessage(groupId: groupId, message: message);
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      Get.snackbar('Group', 'Something went wrong while deleting the message!');
    }
  }

  Future<void> addGroupMembers({required List<String> members}) async {
    try {
      await _groupRepository.addGroupMembers(id: groupId, members: members);
      Get.back();
      Get.snackbar('Groups', 'Group members added!');
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      Get.snackbar('Groups', 'Something went wrong!');
    }
  }

  Future<void> removeMember({required String member}) async {
    try {
      await _groupRepository.removeMember(id: groupId, member: member);
      Get.snackbar('Groups', 'Group member removed!');
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      Get.snackbar('Groups', 'Something went wrong!');
    }
  }

  Future<void> synchronizeWithLocalDB(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final localMessages = messages;
    final firestoreMessages =
        docs.map((e) => GroupMessageModel.fromMap(e.data())).toList();
    dev.log(
      'Firestore messages: ${firestoreMessages.map((e) => e.text).toList()}',
      name: 'Group',
    );
    dev.log(
      'Local messages: ${localMessages.map((e) => e.text).toList()}',
      name: 'Group',
    );

    final firestoreMessageIds =
        firestoreMessages.map((msg) => msg.timestamp).toSet();

    final messagesToDelete = localMessages
        .where((msg) => !firestoreMessageIds.contains(msg.timestamp))
        .toList();
    dev.log('Messages to delete: $messagesToDelete', name: 'Group');

    final messagesToAddOrUpdate = firestoreMessages
        .where((msg) => !localMessages
            .any((localMsg) => localMsg.timestamp == msg.timestamp))
        .toList();
    dev.log('Messages to add or update: $messagesToAddOrUpdate', name: 'Group');

    final messagesToUpdate = firestoreMessages
        .where(
          (msg) => localMessages.any(
            (localMsg) =>
                localMsg.timestamp == msg.timestamp && localMsg != msg,
          ),
        )
        .toList();
    dev.log('Messages to update: $messagesToUpdate', name: 'Group');

    for (final message in messagesToDelete) {
      await _sqliteService.deleteGroupMessage(messageId: message.timestamp);
    }

    for (final message in messagesToAddOrUpdate) {
      dev.log('Storing message through synchronization: $message',
          name: 'Read');
      await _sqliteService.storeGroupMessage(
        groupKey: groupId,
        message: message,
      );
    }

    for (final message in messagesToUpdate) {
      dev.log('Update message: $message', name: 'Group');
      // final localMessage = localMessages.firstWhere(
      //   (e) => e.timestamp == message.timestamp,
      // );
      // await _sqliteService.updateMessage2(
      //   fields: ['local_image_uri', 'local_video_uri'],
      //   values: [localMessage.localImagePath, localMessage.localVideoPath],
      //   id: message.timestamp,
      // );
      await _sqliteService.updateGroupMessage(message: message);
    }

    _messages.value = await _sqliteService.getGroupMessages(groupKey: groupId);
  }
}
