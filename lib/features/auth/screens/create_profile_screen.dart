import 'dart:io';

import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/core/ui/custom_text_field.dart';
import 'package:chat_box/core/ui/primary_button.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/image_utils.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  File? _image;

  final userProfileController = Get.find<UserProfileController>();

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Your Profile',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfilePictureSection(),
                const SizedBox(height: 30),
                CustomTextField(
                  label: 'Your name',
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Your bio',
                  controller: bioController,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 70),
                Obx(() {
                  if (userProfileController.isCreatingUserProfile) {
                    return const CircularProgressIndicator(
                      color: AppColors.myrtleGreen,
                    );
                  } else {
                    return PrimaryButton(
                      title: 'Create Profile',
                      onPressed: _createUserProfile,
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            shadows: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
            ],
          ),
          child: ClipOval(
            child: (_image == null)
                ? Image.asset(
                    Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: IconButton.filled(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.myrtleGreen,
            ),
          ),
        ),
        if (_image != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton.filled(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.grayX11,
              ),
            ),
          ),
      ],
    );
  }

  void _createUserProfile() {
    final email = Get.find<AuthController>().email;
    final user = UserModel(
      email: email!,
      name: nameController.text,
      bio: bioController.text,
      profilePicUrl: '',
      isOnline: true,
    );
    userProfileController.createUserProfile(
      email: email,
      user: user,
      image: _image,
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedImage = await ImageUtils.cropImage(
        imagePath: image.path,
        lockAspectRatio: true,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        initialAspectRatio: CropAspectRatioPreset.square,
      );
      setState(() {
        if (croppedImage != null) {
          _image = File(croppedImage);
        }
      });
    }
  }
}
