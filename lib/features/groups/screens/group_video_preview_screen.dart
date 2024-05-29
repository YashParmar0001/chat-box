import 'package:chat_box/controller/current_group_controller.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class GroupVideoPreviewScreen extends StatefulWidget {
  const GroupVideoPreviewScreen({super.key, required this.groupController});

  final CurrentGroupController groupController;

  @override
  State<GroupVideoPreviewScreen> createState() =>
      _GroupVideoPreviewScreenState();
}

class _GroupVideoPreviewScreenState extends State<GroupVideoPreviewScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    _controller = VideoPlayerController.file(
      widget.groupController.selectedVideo!,
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
    return PopScope(
      onPopInvoked: (didPop) {
        widget.groupController.selectedVideo = null;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white,),
          ),
        ),
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
                    const CircularProgressIndicator(
                        color: AppColors.myrtleGreen),
                    Text(
                      'Please wait',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              if ((!widget.groupController.isSendingVideoMessage)) {
                return GestureDetector(
                  onTap: () {
                    widget.groupController.sendMessage(isMediaMessage: true);
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
      ),
    );
  }
}
