import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../controller/auth_controller.dart';
import '../../../core/ui/profile_photo.dart';

class MembersList extends StatelessWidget {
  const MembersList({super.key, required this.groupController});

  final CurrentGroupController groupController;

  @override
  Widget build(BuildContext context) {
    // final members = groupController.getGroupMembers();
    final currentUserId = Get.find<AuthController>().email!;

    return Obx(() {
      final members = groupController.getGroupMembers(
        Get.find<ChatController>().users,
      );

      return ListView.builder(
        itemCount: members.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final member = members[index];

          return InkWell(
            onLongPress: () {
              if (currentUserId == groupController.group!.createdByUserId &&
                  currentUserId != member.email) {
                _showRemoveMemberDialog(context, member);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ProfilePhoto(url: member.profilePicUrl, dimension: 50),
                      if (member.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const ShapeDecoration(
                              shape: CircleBorder(),
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (currentUserId == member.email) ? 'You' : member.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        member.bio,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.black.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (member.email == groupController.group!.createdByUserId)
                    Text(
                      'Admin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.myrtleGreen,
                            fontFamily: 'Poppins',
                          ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showRemoveMemberDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Text(
            'Do you really want to remove ${user.name}?',
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
                groupController.removeMember(member: user.email);
                Get.back();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
