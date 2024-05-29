import 'dart:io';

import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/core/ui/custom_text_field.dart';
import 'package:chat_box/core/ui/filled_icon_button.dart';
import 'package:chat_box/core/ui/primary_button.dart';
import 'package:chat_box/core/ui/profile_photo.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../model/group_model.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({super.key, required this.group});

  final Group group;

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late final TextEditingController nameController, descriptionController;
  File? _image;

  final groupsController = Get.find<GroupsController>();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.group.name);
    descriptionController = TextEditingController(
      text: widget.group.description,
    );
    super.initState();
  }

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
          'Edit Group',
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
              const SizedBox(height: 30),
              _buildProfilePictureSection(),
              const SizedBox(height: 30),
              CustomTextField(
                label: 'Group name',
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Group description',
                controller: descriptionController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 70),
              Obx(() {
                if (groupsController.isUpdatingGroup) {
                  return const CircularProgressIndicator(
                    color: AppColors.myrtleGreen,
                  );
                } else {
                  return PrimaryButton(
                    title: 'Update Group',
                    onPressed: _updateGroup,
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
                : (widget.group.groupProfilePicUrl != null)
                    ? ProfilePhoto(
                        url: widget.group.groupProfilePicUrl,
                        isGroup: true,
                      )
                    : Image.asset(
                        Assets.imagesUserGroup,
                        fit: BoxFit.cover,
                      ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 0,
          child: FilledIconButton(
            onTap: _pickImageFromGallery,
            icon: Icons.add_photo_alternate_outlined,
            backgroundColor: AppColors.myrtleGreen,
          ),
        ),
        if (_image != null)
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

  void _updateGroup() {
    groupsController.updateGroup(
      image: _image,
      name: nameController.text,
      description: descriptionController.text,
      id: widget.group.id,
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
