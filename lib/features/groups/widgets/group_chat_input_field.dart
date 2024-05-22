import 'dart:io';

import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class GroupChatInputField extends StatelessWidget {
  const GroupChatInputField({super.key, required this.chatController});

  final CurrentGroupController chatController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Obx(() {
        final userId = Get.find<AuthController>().email;
        final isGroupMember = chatController.group?.memberIds.contains(userId);

        if (!(isGroupMember ?? false)) {
          return Text(
            'You can no longer send messages to this group!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          );
        } else {
          return Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showMediaOptions(context),
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: SvgPicture.asset(
                    Assets.iconsAttachment,
                    width: 30,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  decoration: ShapeDecoration(
                    color: AppColors.myrtleGreen.withAlpha(30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextField(
                    // textAlignVertical: TextAlignVertical.top,
                    minLines: 1,
                    maxLines: 5,
                    controller: chatController.messageTextController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        left: 10,
                        bottom: 5,
                        right: 10,
                      ),
                      hintText: 'Write your message',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withOpacity(0.5),
                        fontFamily: 'Caros',
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
                  if (chatController.isSendingMessage) {
                    return const CircularProgressIndicator(
                      color: AppColors.myrtleGreen,
                    );
                  }
                  final enabled = chatController.sendButtonEnabled;
                  return GestureDetector(
                    onTap: () {
                      if (enabled) sendMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: enabled ? AppColors.myrtleGreen : Colors.grey,
                      ),
                      child: SvgPicture.asset(Assets.iconsSend),
                    ),
                  );
                },
              ),
            ],
          );
        }
      }),
    );
  }

  void sendMessage() {
    chatController.sendMessage();
  }

  void _showMediaOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Column(
            children: [
              Text(
                'Share Content',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              _buildMediaOption(
                context: context,
                onTap: () => _selectImage(ImageSource.camera),
                icon: Assets.iconsCamera,
                title: 'Take a Picture',
                description: 'Capture a new photo and share',
              ),
              const SizedBox(height: 20),
              _buildMediaOption(
                context: context,
                onTap: () => _selectImage(ImageSource.gallery),
                icon: Assets.iconsImage,
                title: 'Photo from Gallery',
                description: 'Select a photo from your gallery',
              ),
              const SizedBox(height: 20),
              _buildMediaOption(
                context: context,
                onTap: () => _selectVideo(ImageSource.camera),
                icon: Assets.iconsCameraVideo,
                title: 'Take a Video',
                description: 'Capture a new video and share',
              ),
              const SizedBox(height: 20),
              _buildMediaOption(
                context: context,
                onTap: () => _selectVideo(ImageSource.gallery),
                icon: Assets.iconsVideo,
                title: 'Video from Gallery',
                description: 'Select a video from your gallery',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaOption({
    required BuildContext context,
    required VoidCallback onTap,
    required String icon,
    required String title,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        Get.back();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: AppColors.myrtleGreen.withAlpha(30),
              ),
              child: SvgPicture.asset(
                icon,
                width: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectVideo(ImageSource source) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 10),
    );
    if (video != null) {
      final videoFile = File(video.path);
      debugPrint('Video: $videoFile');
      chatController.selectedVideo = File(video.path);
      sendMessage();
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 50);
    if (image != null) {
      chatController.selectedImage = File(image.path);
      if (source == ImageSource.gallery) {
        _showImageConfirmationDialog();
      } else {
        sendMessage();
      }
    }
  }

  void _showImageConfirmationDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(chatController.selectedImage!),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      // chatController.selectedImage = null;
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      sendMessage();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
