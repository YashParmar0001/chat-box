import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/features/groups/screens/group_details_screen.dart';
import 'package:chat_box/features/groups/widgets/group_chat_bubble.dart';
import 'package:chat_box/features/groups/widgets/group_chat_input_field.dart';
import 'package:chat_box/model/group_message_model.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../controller/auth_controller.dart';
import '../../../generated/assets.dart';
import '../../../utils/formatting_utils.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({
    super.key,
    required this.userId,
    required this.groupChatController,
  });

  final String userId;
  final CurrentGroupController groupChatController;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (widget.groupChatController.isLoadingMessages) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;

      if (maxScroll - currentScroll <= 100 &&
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        if (!widget.groupChatController.atMaxLimit &&
            !widget.groupChatController.isLoadingMessages) {
          widget.groupChatController.getMoreMessages();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final groupsController = Get.find<GroupsController>();
          final group = groupsController.groups
              .firstWhere((e) => e.id == widget.groupChatController.groupId);
          final typingStatuses = widget.groupChatController.typingStatuses
              .where((e) => e.isTyping)
              .toList();
          final users = Get.find<ChatController>().users;

          final currentUserId = Get.find<AuthController>().email!;
          final typingUsers = typingStatuses
              .where(
                (e) => e.userId != currentUserId,
              )
              .toList();
          final typingUser = typingUsers.isNotEmpty
              ? users.firstWhere((e) => e.email == typingStatuses.first.userId)
              : null;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.to(
              () => GroupDetailsScreen(
                groupController: widget.groupChatController,
              ),
            ),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: group.groupProfilePicUrl ?? '',
                  placeholder: (context, url) {
                    return ClipOval(
                      child: Image.asset(
                        Assets.iconsTeam,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    );
                  },
                  imageBuilder: (context, imageProvider) {
                    return ClipOval(
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return ClipOval(
                      child: Image.asset(
                        Assets.iconsTeam,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
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
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    (typingUser != null)
                        ? Text(
                            '${typingUser.name} is typing...',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.myrtleGreen,
                                    ),
                          )
                        : Text(
                            '${group.memberIds.length} Members',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.black.withOpacity(0.7),
                                ),
                          ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                final list = widget.groupChatController.messages;
                dev.log('Updated messages: $list', name: 'Chat');
                return Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      itemCount: _calculateSectionCount(list),
                      itemBuilder: (context, index) {
                        return _buildMessageSections(context, index);
                      },
                    ),
                    if (widget.groupChatController.isLoadingMessages)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          GroupChatInputField(chatController: widget.groupChatController),
          // const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMessageSections(BuildContext context, int sectionIndex) {
    final sectionMessages = _getSectionMessages(
      widget.groupChatController.messages,
      sectionIndex,
    );

    return Column(
      children: [
        Container(
          height: 40,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            FormattingUtils.getSectionTitle(sectionMessages.first.time),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sectionMessages.length,
          itemBuilder: (context, index) {
            final message = sectionMessages[index];
            final isCurrentUser =
                Get.find<AuthController>().email == message.senderId;
            // dev.log(
            //   'Message: ${message.text} |'
            //   'Read by: ${message.readBy.length} | '
            //   'Group members: ${widget.groupChatController.group?.memberIds.length ?? 0}',
            //   name: 'GroupChat',
            // );
            final isRead = message.readBy.length >=
                (widget.groupChatController.group?.memberIds.length ?? 0) - 1;

            return Obx(
              () => GroupChatBubble(
                message: sectionMessages[index],
                isCurrentUser: isCurrentUser,
                isRead: isRead,
                user: Get.find<ChatController>().users.firstWhere(
                  (e) => e.email == message.senderId,
                  orElse: () {
                    return const UserModel(
                      email: '',
                      name: 'Unknown',
                      bio: '',
                      isOnline: false,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  int _calculateSectionCount(List<GroupMessageModel> messages) {
    Set<DateTime> dates = {};
    for (var message in messages) {
      dates.add(
        DateTime(
          message.time.year,
          message.time.month,
          message.time.day,
        ),
      );
    }
    return dates.length;
  }

  List<GroupMessageModel> _getSectionMessages(
    List<GroupMessageModel> messages,
    int sectionIndex,
  ) {
    Set<DateTime> dates = {};
    for (var message in messages) {
      dates.add(
        DateTime(
          message.time.year,
          message.time.month,
          message.time.day,
        ),
      );
    }
    final sectionDate = dates.toList()[sectionIndex];
    return messages
        .where(
          (message) =>
              DateTime(
                message.time.year,
                message.time.month,
                message.time.day,
              ) ==
              sectionDate,
        )
        .toList();
  }
}
