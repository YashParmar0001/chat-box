import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/features/groups/screens/create_group_screen.dart';
import 'package:chat_box/features/groups/screens/edit_group_screen.dart';
import 'package:chat_box/features/groups/screens/group_chat_screen.dart';
import 'package:chat_box/features/groups/screens/group_details_screen.dart';
import 'package:chat_box/model/group_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupsController = Get.find<GroupsController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Groups',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Obx(() {
        final list = groupsController.userGroups;

        if (list.isEmpty) {
          return Center(
            child: Text(
              'There are no Groups yet,\nTap + to create one!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.6),
                  ),
            ),
          );
        }

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _Group(group: list[index]);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create_group',
        onPressed: () => Get.to(() => const CreateGroupScreen()),
        backgroundColor: AppColors.myrtleGreen,
        label: Text(
          'Create Group',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => GroupChatScreen(
          userId: Get.find<AuthController>().email!,
          groupChatController: Get.put(
            CurrentGroupController(
              groupId: group.id,
              currentUserId: Get.find<AuthController>().email!,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: group.groupProfilePicUrl ?? '',
              placeholder: (context, url) {
                return ClipOval(
                  child: Image.asset(
                    Assets.imagesUserGroup,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                return ClipOval(
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return ClipOval(
                  child: Image.asset(
                    Assets.imagesUserGroup,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${group.memberIds.length} Members',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
