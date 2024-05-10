import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/features/home/widgets/chat_bubble.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:chat_box/utils/formatting_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../generated/assets.dart';
import '../../../model/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.user,
    required this.chatController,
  });

  final UserModel user;
  final CurrentChatController2 chatController;

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
        widget.chatController.getMoreMessages();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                final list = widget.chatController.messages;
                dev.log('Updated messages: $list', name: 'Chat');
                return Stack(
                  children: [
                    // ListView.builder(
                    //   controller: scrollController,
                    //   reverse: true,
                    //   itemCount: list.length,
                    //   itemBuilder: (context, index) {
                    //     return ChatBubble(
                    //       isCurrentUser: list[index].senderId ==
                    //           Get.find<AuthController>().email!,
                    //       message: list[index],
                    //     );
                    //   },
                    // ),
                    ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      itemCount: _calculateSectionCount(list),
                      itemBuilder: (context, index) {
                        return _buildMessageSections(context, index);
                      },
                    ),
                    // CustomScrollView(
                    //   slivers: [
                    //     SliverList(
                    //       delegate: SliverChildBuilderDelegate(
                    //         _buildMessageSections,
                    //         childCount: _calculateSectionCount(list),
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextField(
                      controller: widget.chatController.messageTextController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        hintText: 'Type something...',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (value) {
                        if (value.isNotEmpty || value != '') sendMessage();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () {
                    final enabled = widget.chatController.sendButtonEnabled;
                    return IconButton(
                      onPressed: () {
                        if (enabled) sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: enabled ? AppColors.tartOrange : Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
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

  void sendMessage() {
    widget.chatController.sendMessage();
  }
}
