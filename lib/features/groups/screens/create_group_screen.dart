import 'dart:io';

import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/core/ui/custom_text_field.dart';
import 'package:chat_box/core/ui/primary_button.dart';
import 'package:chat_box/core/ui/profile_photo.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final nameController = TextEditingController(),
      descriptionController = TextEditingController();
  File? _image;
  final userIds = <String>[];

  final groupsController = Get.find<GroupsController>();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Group',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildProfilePictureSection(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CustomTextField(
                      label: 'Group name',
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Group Description',
                controller: descriptionController,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 40),
              Text(
                'Add Members',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              Obx(() {
                final chatController = Get.find<ChatController>();
                final currentUserId = Get.find<AuthController>().email!;
                final users = chatController.users
                    .where((e) => !(e.email == currentUserId))
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      child: InkWell(
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          setState(() {
                            if (userIds.contains(user.email)) {
                              userIds.remove(user.email);
                            } else {
                              userIds.add(user.email);
                            }
                          });
                        },
                        child: Row(
                          children: [
                            ProfilePhoto(
                              url: user.profilePicUrl,
                              dimension: 50,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const Spacer(),
                            RoundCheckBox(
                              animationDuration: const Duration(
                                milliseconds: 100,
                              ),
                              isChecked: userIds.contains(user.email),
                              size: 30,
                              onTap: (selected) {
                                if (selected != null) {
                                  if (selected) {
                                    userIds.add(user.email);
                                  } else {
                                    userIds.removeWhere((e) => e == user.email);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 20),
              Obx(() {
                if (groupsController.isCreatingGroup) {
                  return const CircularProgressIndicator(
                    color: AppColors.myrtleGreen,
                  );
                } else {
                  return PrimaryButton(
                    title: 'Create Group',
                    onPressed: _createGroup,
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
          width: 80,
          height: 80,
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
          child: GestureDetector(
            onTap: _pickImageFromGallery,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const ShapeDecoration(
                shape: CircleBorder(),
                color: AppColors.myrtleGreen,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        if (_image != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.grey,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _createGroup() {
    final email = Get.find<AuthController>().email;
    groupsController.createGroup(
      image: _image,
      name: nameController.text,
      description: descriptionController.text,
      userId: email!,
      users: userIds,
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
      setState(() {
        _image = File(image.path);
      });
    }
  }
}
