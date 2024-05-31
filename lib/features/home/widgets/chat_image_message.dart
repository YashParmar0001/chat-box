import 'dart:io';
import 'dart:developer' as dev;

import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/controller/settings_controller.dart';
import 'package:chat_box/model/message_model.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';

class ChatImageMessage extends StatefulWidget {
  const ChatImageMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.chatController,
  });

  final MessageModel message;
  final bool isCurrentUser;
  final CurrentChatController chatController;

  @override
  State<ChatImageMessage> createState() => _ChatImageMessageState();
}

class _ChatImageMessageState extends State<ChatImageMessage> {
  bool isDownloadingImage = false;
  final autoDownload = Get.find<SettingsController>().autoDownload;

  @override
  void initState() {
    if (autoDownload ||
        (widget.message.localImagePath == null && widget.isCurrentUser)) {
      isDownloadingImage = true;
      widget.chatController.processLocalImagePath(widget.message);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('Building group image', name: 'GroupImage');
    ImageProvider imageProvider;

    if (widget.message.localImagePath == null) {
      imageProvider = BlurhashFfiImage(widget.message.blurImageHash!);
    } else {
      isDownloadingImage = false;
      imageProvider = FileImage(File(widget.message.localImagePath!));
    }

    final placeholder = Image.asset(
      Assets.imagesPlaceholderImage,
      fit: BoxFit.cover,
      height: 150,
    );

    return GestureDetector(
      onTap: () {
        if (widget.message.localImagePath != null) {
          showImageViewer(
            context,
            imageProvider,
            swipeDismissible: true,
            useSafeArea: true,
            doubleTapZoomable: true,
            immersive: false,
          );
        }
      },
      child: Stack(
        children: [
          Image(
            image: imageProvider,
            fit: BoxFit.cover,
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) => placeholder,
          ),
          if (widget.isCurrentUser)
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
          if (isDownloadingImage)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          if (widget.message.localImagePath == null && !isDownloadingImage)
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isDownloadingImage = true;
                      widget.chatController.processLocalImagePath(
                        widget.message,
                      );
                    });
                  },
                  child: SvgPicture.asset(Assets.iconsDownload, width: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
