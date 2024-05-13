import 'dart:io';

import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/colors.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key, required this.chatController});

  final CurrentChatController chatController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => _showMediaOptions(context),
            icon: const Icon(
              Icons.perm_media_outlined,
              color: AppColors.tartOrange,
            ),
          ),
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                  hintText: 'Type something...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              if (chatController.isSendingMessage) {
                return const CircularProgressIndicator(
                  color: AppColors.tartOrange,
                );
              }
              final enabled = chatController.sendButtonEnabled;
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaOption(
                context: context,
                icon: Icons.add_photo_alternate_outlined,
                label: 'Send Photo',
                onPressed: () => _showPhotoOptions(context),
              ),
              _buildMediaOption(
                context: context,
                icon: Icons.video_collection_outlined,
                label: 'Send Video',
                onPressed: () => _showVideoOptions(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaOption(
                context: context,
                icon: Icons.add_photo_alternate_outlined,
                label: 'From Gallery',
                onPressed: () {
                  // Get.back();
                  _selectImage(ImageSource.gallery);
                },
              ),
              _buildMediaOption(
                context: context,
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onPressed: () => _selectImage(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaOption(
                context: context,
                icon: Icons.video_collection_outlined,
                label: 'From Gallery',
                onPressed: () => _selectVideo(ImageSource.gallery),
              ),
              _buildMediaOption(
                context: context,
                icon: Icons.video_camera_back_outlined,
                label: 'Take Video',
                onPressed: () => _selectVideo(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: () {
        Get.back();
        onPressed();
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.tartOrange,),
          SizedBox(
            width: 60,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
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
                      chatController.selectedImage = null;
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
