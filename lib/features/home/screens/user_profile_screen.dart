import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/core/ui/profile_photo.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = Get.find<AuthController>().email! == user.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          if (!isCurrentUser)
            PopupMenuButton<String>(
              itemBuilder: (context) {
                final currentUser =
                    Get.find<UserProfileController>().currentUserProfile!;
                final isBlocked = currentUser.blockedUsers.contains(user.email);
                return [
                  PopupMenuItem(
                    onTap: () {
                      if (isBlocked) {
                        _showUnblockUserDialog(context);
                      } else {
                        _showBlockUserDialog(context);
                      }
                    },
                    child: Text(isBlocked ? 'Unblock User' : 'Block User'),
                  ),
                ];
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                ProfilePhoto(url: user.profilePicUrl),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 50),
            _buildDataField(
              context,
              'Name',
              user.name,
            ),
            const SizedBox(height: 30),
            _buildDataField(
              context,
              'Bio',
              user.bio,
            ),
            const SizedBox(height: 30),
            _buildDataField(
              context,
              'Email',
              user.email,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataField(BuildContext context, String label, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          data,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  void _showBlockUserDialog(BuildContext context) {
    final chatController = Get.find<ChatController>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Text(
            'Do you really want block ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                chatController.blockUser(user.email);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showUnblockUserDialog(BuildContext context) {
    final chatController = Get.find<ChatController>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Text(
            'Do you really want unblock ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                chatController.unblockUser(user.email);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
