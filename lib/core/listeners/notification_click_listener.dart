import 'dart:developer';

import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/features/groups/screens/group_chat_screen.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../controller/auth_controller.dart';
import '../../controller/current_chat_controller.dart';
import '../../features/home/screens/chat_screen.dart';

const notificationClickListener = listener;

void listener(OSNotificationClickEvent event) {
  final data = event.notification.additionalData;
  if (data != null) {
    log('Additional data: $data', name: 'Notification');
    if (data['group_id'] != null) {
      final authController = Get.find<AuthController>();
      if (authController.isAuthenticated) {
        Get.to(
          () => GroupChatScreen(
            groupChatController: Get.put(
              CurrentGroupController(
                groupId: data['group_id'],
                currentUserId: authController.email!,
              ),
            ),
          ),
        );
      }
    } else {
      final authController = Get.find<AuthController>();
      if (authController.isAuthenticated) {
        Get.to(
          () => ChatScreen(
            userId: data['sender_id'],
            chatController: Get.put(
              CurrentChatController(
                currentUserId: data['receiver_id'],
                otherUserId: data['sender_id'],
              ),
            ),
          ),
        );
      }
    }
  }
}
