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
        children: [
          IconButton(
            onPressed: () => _showBottomSheet(context),
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                  _selectImage(ImageSource.gallery);
                },
                icon: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_sharp,
                    ),
                    Text('From gallery'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.back();
                  _selectImage(ImageSource.camera);
                },
                icon: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                    ),
                    Text('Take photo'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
