import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/controller/current_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key, required this.chatController});

  final CurrentChatController chatController;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        chatController.selectedImage = null;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(),
        body: PhotoView(
          imageProvider: FileImage(chatController.selectedImage!),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Obx(() {
                if ((!chatController.isSendingImageMessage)) {
                  return GestureDetector(
                    onTap: () {
                      chatController.sendMessage(isMediaMessage: true);
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
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
