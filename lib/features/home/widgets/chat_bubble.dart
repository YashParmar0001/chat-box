import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/core/screens/video_player_screen.dart';
import 'package:chat_box/features/home/widgets/chat_image_message.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.chatController,
  });

  final MessageModel message;
  final bool isCurrentUser;
  final CurrentChatController chatController;

  @override
  Widget build(BuildContext context) {
    final isMediaMessage = message.imageUrl != null || message.videoUrl != null;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: EdgeInsets.only(
                  left: isCurrentUser ? 50 : 10,
                  right: isCurrentUser ? 10 : 50,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isCurrentUser ? AppColors.myrtleGreen : AppColors.grayX11,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isCurrentUser ? 12 : 0),
                    topRight: Radius.circular(isCurrentUser ? 0 : 12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Stack(
                        children: [
                          Builder(
                            builder: (context) {
                              if (message.imageUrl != null) {
                                return ChatImageMessage(
                                  key: Key(message.timestamp.toString()),
                                  message: message,
                                  isCurrentUser: isCurrentUser,
                                  chatController: chatController,
                                );
                              } else if (message.videoUrl != null) {
                                return _buildVideo(context);
                              } else {
                                return Text(
                                  message.text,
                                  maxLines: 10,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isCurrentUser
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                );
                              }
                            },
                          ),
                          if (isCurrentUser && isMediaMessage)
                            Positioned(
                              right: 5,
                              bottom: 5,
                              child: _buildTicks(),
                            ),
                        ],
                      ),
                    ),
                    if (isCurrentUser && !isMediaMessage)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: _buildTicks(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: isCurrentUser ? 0 : 10,
                  right: isCurrentUser ? 10 : 0,
                ),
                child: Text(
                  DateFormat.jm().format(message.time),
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

  Widget _buildTicks() {
    return Builder(
      builder: (context) {
        if (message.isRead || message.isDelivered) {
          return SvgPicture.asset(
            Assets.iconsDoubleTick,
            width: 20,
            color: message.isRead ? Colors.blue : AppColors.grayX11,
          );
        } else {
          return SvgPicture.asset(
            Assets.iconsSingleTick,
            width: 15,
            color: AppColors.grayX11,
          );
        }
      },
    );
  }

  Widget _buildVideo(BuildContext context) {
    Widget videoPlaceholder = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.video_camera_back_outlined,
          color: isCurrentUser ? Colors.white : AppColors.myrtleGreen,
        ),
        const SizedBox(width: 10),
        Text(
          'Video',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontFamily: 'Poppins',
              ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        Get.to(
          () => VideoPlayerScreen(
            videoUrl: message.videoUrl!,
            localVideoPath: message.localVideoPath,
          ),
        );
      },
      child: (message.videoThumbnailUrl != null)
          ? Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: message.videoThumbnailUrl!,
                  imageBuilder: (context, imageProvider) {
                    return Stack(
                      children: [
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          // height: 150,
                          width: 200,
                        ),
                        const Positioned.fill(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    );
                  },
                  errorWidget: (context, url, error) => videoPlaceholder,
                  placeholder: (context, url) => videoPlaceholder,
                ),
                if (isCurrentUser)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : videoPlaceholder,
    );
  }

  void _showDeleteMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'Do you really want to delete this message?',
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
                Get.find<CurrentChatController>().unSendMessage(
                  message,
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
