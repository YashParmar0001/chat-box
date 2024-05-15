import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/features/home/screens/user_profile_screen.dart';
import 'package:chat_box/features/home/widgets/chat_bubble.dart';
import 'package:chat_box/features/home/widgets/chat_input_field.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:chat_box/utils/formatting_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';
import '../../../model/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.user,
    required this.chatController,
  });

  final UserModel user;
  final CurrentChatController chatController;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (widget.chatController.isLoadingMessages) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;

      if (maxScroll - currentScroll <= 100 &&
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        if (!widget.chatController.atMaxLimit) {
          widget.chatController.getMoreMessages();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Get.to(() => UserProfileScreen(user: widget.user)),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: widget.user.profilePicUrl ?? '',
                placeholder: (context, url) {
                  return ClipOval(
                    child: Image.asset(
                      Assets.imagesUserProfile,
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
                      Assets.imagesUserProfile,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                widget.user.name,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                final list = widget.chatController.messages;
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
                    if (widget.chatController.isLoadingMessages)
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
          ChatInputField(chatController: widget.chatController),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMessageSections(BuildContext context, int sectionIndex) {
    final sectionMessages = _getSectionMessages(
      widget.chatController.messages,
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
            return ChatBubble(
              message: sectionMessages[index],
              isCurrentUser: Get.find<AuthController>().email ==
                  sectionMessages[index].senderId,
            );
          },
        ),
      ],
    );
  }

  int _calculateSectionCount(List<MessageModel> messages) {
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

  List<MessageModel> _getSectionMessages(
    List<MessageModel> messages,
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
