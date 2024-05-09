import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/features/home/widgets/chat_bubble.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';

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

      if (maxScroll - currentScroll <= 100) {
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
                return Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(
                          isCurrentUser: list[index].senderId ==
                              Get.find<AuthController>().email!,
                          message: list[index],
                        );
                      },
                    ),
                    // ListView.builder(
                    //   controller: scrollController,
                    //   reverse: true,
                    //   itemCount: 100,
                    //   itemBuilder: (context, index) {
                    //     return ChatBubble(
                    //       isCurrentUser: index.isOdd,
                    //       text: 'Hello everyone',
                    //       time: DateTime.now(),
                    //     );
                    //   },
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

  void sendMessage() {
    widget.chatController.sendMessage();
  }
}
