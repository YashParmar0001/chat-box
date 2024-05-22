import 'dart:developer' as dev;

import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/model/group_model.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MembersSelectField extends StatelessWidget {
  const MembersSelectField({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final members = List<UserModel>.from(Get.find<ChatController>().users);
    members.removeWhere((e) => e.email == group.createdByUserId);

    return MultiSelectBottomSheet(
      initialChildSize: 0.9,
      // minChildSize: 0.5,
      maxChildSize: 1,
      checkColor: Colors.white,
      selectedColor: AppColors.myrtleGreen,
      cancelText: Text(
        'Cancel',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      listType: MultiSelectListType.LIST,
      // searchable: true,
      title: Text(
        'Add or Remove Users',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      items: members.map((e) {
        return MultiSelectItem(e.email, e.name);
      }).toList(),
      onConfirm: (values) {
        // final controller = Get.find<GroupsController>();
        // controller.updateGroupMembers(id: group.id, members: values);
      },
      onSelectionChanged: (members) {
        dev.log('Selected $members', name: 'Group');
      },
      initialValue: group.memberIds,
    );
  }
}
