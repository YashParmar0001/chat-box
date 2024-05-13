import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/features/home/screens/video_player_screen.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:chat_box/utils/formatting_utils.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                      isCurrentUser ? AppColors.tartOrange : AppColors.grayX11,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isCurrentUser ? 12 : 0),
                    topRight: Radius.circular(isCurrentUser ? 0 : 12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    if (message.imageUrl != null) {
                      return _buildImage();
                    } else if (message.videoUrl != null) {
                      return _buildVideo(context);
                    } else {
                      return Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  isCurrentUser ? Colors.white : Colors.black,
                            ),
                      );
                    }
                  },
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

  CachedNetworkImage _buildImage() {
    return CachedNetworkImage(
      imageUrl: message.imageUrl!,
      imageBuilder: (context, imageProvider) {
        return GestureDetector(
          onTap: () {
            showImageViewer(
              context,
              imageProvider,
              swipeDismissible: true,
              useSafeArea: true,
              doubleTapZoomable: true,
              immersive: false,
            );
          },
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
            height: 250,
          ),
        );
      },
      placeholder: (context, url) {
        return Image.asset(
          Assets.imagesPlaceholderImage,
          fit: BoxFit.cover,
          height: 250,
        );
      },
      errorWidget: (context, url, error) {
        return Image.asset(
          Assets.imagesPlaceholderImage,
          fit: BoxFit.cover,
          height: 250,
        );
      },
    );
  }

  Widget _buildVideo(BuildContext context) {
    Widget videoPlaceholder = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.video_camera_back_outlined,
          color: isCurrentUser ? Colors.white : AppColors.tartOrange,
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
        Get.to(() => VideoPlayerScreen(videoUrl: message.videoUrl!));
      },
      child: (message.videoThumbnailUrl != null)
          ? CachedNetworkImage(
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
                Get.find<CurrentChatController>().deleteMessage(
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
