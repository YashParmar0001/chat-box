import 'package:chat_box/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageUtils {
  static Future<String?> cropImage({
    required String imagePath,
    required List<CropAspectRatioPreset> aspectRatioPresets,
    bool lockAspectRatio = false,
    CropAspectRatioPreset initialAspectRatio = CropAspectRatioPreset.original,
  }) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: aspectRatioPresets,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.myrtleGreen,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: initialAspectRatio,
          lockAspectRatio: lockAspectRatio,
          activeControlsWidgetColor: AppColors.myrtleGreen,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      return croppedFile.path;
    } else {
      return null;
    }
  }
}
