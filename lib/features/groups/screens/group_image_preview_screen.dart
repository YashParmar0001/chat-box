import 'package:chat_box/controller/current_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class GroupImagePreviewScreen extends StatelessWidget {
  const GroupImagePreviewScreen({super.key, required this.groupController});

  final CurrentGroupController groupController;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        groupController.selectedImage = null;
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
        body: PhotoView(
          imageProvider: FileImage(groupController.selectedImage!),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Obx(() {
                if ((!groupController.isSendingImageMessage)) {
                  return GestureDetector(
                    onTap: () {
                      groupController.sendMessage(isMediaMessage: true);
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
