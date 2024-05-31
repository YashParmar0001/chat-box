import 'dart:developer';
import 'dart:io';

import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chat_box/controller/settings_controller.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:chat_box/model/group_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/screens/video_player_screen.dart';

class GroupVideoMessage extends StatefulWidget {
  const GroupVideoMessage({
    super.key,
    required this.isCurrentUser,
    required this.message,
    required this.groupController,
  });

  final bool isCurrentUser;
  final GroupMessageModel message;
  final CurrentGroupController groupController;

  @override
  State<GroupVideoMessage> createState() => _GroupVideoMessageState();
}

class _GroupVideoMessageState extends State<GroupVideoMessage> {
  bool isDownloadingVideo = false;
  final autoDownload = Get.find<SettingsController>().autoDownload;

  @override
  void initState() {
    if (widget.message.localVideoPath == null ||
        widget.message.localThumbnailPath == null) {
      if (autoDownload || widget.isCurrentUser) {
        log('Downloading video', name: 'GroupVideo');
        isDownloadingVideo = true;
        widget.groupController.processLocalVideoPath(widget.message);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider thumbnailProvider;

    if (widget.message.localThumbnailPath == null) {
      thumbnailProvider = BlurhashFfiImage(widget.message.blurThumbnailHash!);
    } else {
      isDownloadingVideo = false;
      thumbnailProvider = FileImage(File(widget.message.localThumbnailPath!));
    }

    return Stack(
      children: [
        Image(
          image: thumbnailProvider,
          fit: BoxFit.cover,
          width: 200,
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
        if (isDownloadingVideo)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        if (widget.message.localVideoPath == null && !isDownloadingVideo)
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isDownloadingVideo = true;
                    widget.groupController.processLocalVideoPath(
                      widget.message,
                    );
                  });
                },
                child: SvgPicture.asset(Assets.iconsDownload, width: 40),
              ),
            ),
          ),
        if (widget.message.localVideoPath != null)
          Positioned.fill(
            child: Center(
              child: IconButton(
                onPressed: () => Get.to(
                  () => VideoPlayerScreen(
                    videoUrl: widget.message.videoUrl!,
                    localVideoPath: widget.message.localVideoPath,
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
