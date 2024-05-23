
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({super.key, required this.chatController});

  final CurrentChatController chatController;

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    _controller = VideoPlayerController.file(
      widget.chatController.selectedVideo!,
    );
    _controller.initialize().then((_) => setState(() {}));

    _chewieController = ChewieController(videoPlayerController: _controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController..play(),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.myrtleGreen),
                  Text(
                    'Please wait',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            if ((!widget.chatController.isSendingVideoMessage)) {
              return GestureDetector(
                onTap: () {
                  widget.chatController.sendMessage(isMediaMessage: true);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.all(8),
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: AppColors.myrtleGreen,
                  ),
                  child: SvgPicture.asset(Assets.iconsSend),
                ),
              );
            } else {
              return const CircularProgressIndicator(
                color: AppColors.myrtleGreen,
              );
            }
          }),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
