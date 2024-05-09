import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/utils/formatting_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final MessageModel message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (isCurrentUser) {
            _showDeleteMessageDialog(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.only(
                  left: isCurrentUser ? 50 : 10,
                  right: isCurrentUser ? 10 : 50,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isCurrentUser ? AppColors.tartOrange : AppColors.grayX11,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isCurrentUser ? 12 : 0),
                    topRight: Radius.circular(isCurrentUser ? 0 : 12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                ),
                child: Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCurrentUser ? Colors.white : Colors.black,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: isCurrentUser ? 0 : 10,
                  right: isCurrentUser ? 10 : 0,
                ),
                child: Text(
                  FormattingUtils.formatMessageTime(message.time),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('Do you really want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.find<CurrentChatController2>().deleteMessage(
                  message.timestamp.toString(),
                );
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
