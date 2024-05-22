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
    final members = groupController.getGroupMembers();
    final currentUserId = Get.find<AuthController>().email!;

    return ListView.builder(
      itemCount: members.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final member = members[index];

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
          ),
          child: GestureDetector(
            child: InkWell(
              onLongPress: () {
                if (currentUserId == groupController.group!.createdByUserId &&
                    currentUserId != member.email) {
                  _showRemoveMemberDialog(context, member);
                }
              },
              child: Row(
                children: [
                  ProfilePhoto(url: member.profilePicUrl, dimension: 50),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (currentUserId == member.email) ? 'You' : member.name,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        member.bio,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
          ),
        );
      },
    );
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
