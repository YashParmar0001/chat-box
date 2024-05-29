import 'dart:io';
import 'dart:developer' as dev;

import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/core/ui/custom_text_field.dart';
import 'package:chat_box/core/ui/filled_icon_button.dart';
import 'package:chat_box/core/ui/primary_button.dart';
import 'package:chat_box/core/ui/profile_photo.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:chat_box/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController bioController;
  File? _image;
  String? oldProfileUrl;

  final userProfileController = Get.find<UserProfileController>();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.user.name);
    bioController = TextEditingController(text: widget.user.bio);
    oldProfileUrl = widget.user.profilePicUrl;
    super.initState();
  }

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
          'Update Profile',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Padding(
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
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Your bio',
                controller: bioController,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 70),
              Obx(() {
                if (userProfileController.isUpdatingUserProfile) {
                  return const CircularProgressIndicator(
                    color: AppColors.myrtleGreen,
                  );
                } else {
                  return PrimaryButton(
                    title: 'Update Profile',
                    onPressed: _createUserProfile,
                  );
                }
              }),
            ],
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
            child: (_image != null)
                ? Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  )
                : (oldProfileUrl != null)
                    ? ProfilePhoto(url: oldProfileUrl)
                    : Image.asset(
                        Assets.imagesUserProfile,
                        fit: BoxFit.cover,
                      ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 0,
          child: FilledIconButton(
            onTap: _pickImageFromGallery,
            backgroundColor: AppColors.myrtleGreen,
            icon: Icons.add_photo_alternate_outlined,
          ),
        ),
        if (_image != null || oldProfileUrl != null)
          Positioned(
            top: 0,
            right: 10,
            child: FilledIconButton(
              onTap: _removeImage,
              icon: Icons.delete_rounded,
              backgroundColor: Colors.grey,
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
      profilePicUrl: oldProfileUrl,
      isOnline: true,
    );
    dev.log('OldProfileUrl: $oldProfileUrl | Image: $_image', name: 'Profile');
    userProfileController.updateUserProfile(
      email: email,
      user: user,
      image: _image,
      removeProfilePhoto: oldProfileUrl == null && _image == null,
    );
  }

  void _removeImage() {
    setState(() {
      if (_image != null) {
        _image = null;
      } else {
        oldProfileUrl = null;
      }
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
