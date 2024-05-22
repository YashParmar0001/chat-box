import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/core/ui/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

import '../../../core/ui/profile_photo.dart';

class AddMembersScreen extends StatefulWidget {
  const AddMembersScreen({super.key, required this.controller});

  final CurrentGroupController controller;

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final userIds = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Members',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            Obx(
              () {
                final users = Get.find<ChatController>()
                    .users
                    .where(
                      (e) => !widget.controller.group!.memberIds.contains(
                        e.email,
                      ),
                    )
                    .toList();

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'There are no users to add to this group',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  );
                }else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          child: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              setState(() {
                                if (userIds.contains(user.email)) {
                                  userIds.remove(user.email);
                                } else {
                                  userIds.add(user.email);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                ProfilePhoto(
                                  url: user.profilePicUrl,
                                  dimension: 50,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                const Spacer(),
                                RoundCheckBox(
                                  animationDuration: const Duration(
                                    milliseconds: 100,
                                  ),
                                  isChecked: userIds.contains(user.email),
                                  size: 30,
                                  onTap: (selected) {
                                    if (selected != null) {
                                      if (selected) {
                                        userIds.add(user.email);
                                      } else {
                                        userIds
                                            .removeWhere((e) => e == user.email);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            if (userIds.isNotEmpty)
              PrimaryButton(
                title: 'Continue',
                onPressed: () {
                  widget.controller.addGroupMembers(members: userIds);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
