import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/features/groups/screens/add_members_screen.dart';
import 'package:chat_box/features/groups/screens/edit_group_screen.dart';
import 'package:chat_box/features/groups/widgets/members_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../core/ui/profile_photo.dart';

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key, required this.groupController});

  final CurrentGroupController groupController;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Details',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          Obx(
            () {
              if (groupController.group == null) {
                return const SizedBox();
              }

              if ((groupController.group?.createdByUserId ?? '') ==
                  authController.email!) {
                return IconButton(
                  onPressed: () => _showDeleteGroupDialog(context),
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                  ),
                );
              } else {
                if (groupController.group?.memberIds
                        .contains(authController.email) ??
                    false) {
                  return IconButton(
                    onPressed: () => _showExitGroupDialog(context),
                    icon: const Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.red,
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Obx(
          () {
            if (groupController.isFetchingGroupDetails) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.myrtleGreen,
                ),
              );
            } else {
              final group = groupController.group;
              if (group != null) {
                return Column(
                  children: [
                    const SizedBox(height: 30),
                    ProfilePhoto(
                      url: group.groupProfilePicUrl,
                      dimension: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          group.description,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          group.memberIds.length.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Member${group.memberIds.length > 1 ? 's' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: AppColors.myrtleGreen,
                              ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildAddMember(context),
                    const SizedBox(height: 20),
                    MembersList(groupController: groupController),
                  ],
                );
              } else {
                return Text(
                  'Error loading Group details',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: Obx(
        () {
          if ((groupController.group?.createdByUserId ?? '') ==
              authController.email!) {
            return FloatingActionButton(
              heroTag: 'edit_group',
              onPressed: () => Get.to(
                () => EditGroupScreen(group: groupController.group!),
              ),
              backgroundColor: AppColors.myrtleGreen,
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildAddMember(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => AddMembersScreen(controller: groupController),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: AppColors.myrtleGreen,
            ),
            child: const Icon(
              Icons.person_add_alt_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Add Member',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'Do you really want to delete this group?',
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
                final id = groupController.group?.id;
                if (id != null) {
                  Get.find<GroupsController>().deleteGroup(id: id);
                }
                Get.back();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showExitGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'Do you really want to exit the group?',
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
                final id = Get.find<AuthController>().email;
                if (id != null) {
                  groupController.exitGroup(id);
                }
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
