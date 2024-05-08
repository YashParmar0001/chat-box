import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/features/profile/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../generated/assets.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userProfileController = Get.find<UserProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          IconButton(
            onPressed: authController.logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Obx(
          () {
            if (userProfileController.isFetchingUserProfile) {
              return const CircularProgressIndicator(
                color: AppColors.tartOrange,
              );
            } else {
              final user = userProfileController.currentUserProfile;
              if (user != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Spacer(),
                        _buildProfilePictureSection(user.profilePicUrl),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 50),
                    _buildDataField(
                      context,
                      'Name',
                      user.name,
                    ),
                    const SizedBox(height: 30),
                    _buildDataField(
                      context,
                      'Bio',
                      user.bio,
                    ),
                    const SizedBox(height: 30),
                    _buildDataField(
                      context,
                      'Email',
                      authController.email!,
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }
          },
        ),
      ),
      floatingActionButton: (userProfileController.currentUserProfile != null)
          ? FloatingActionButton(
              heroTag: 'edit_profile',
              onPressed: () => Get.to(
                () => EditProfileScreen(
                  user: userProfileController.currentUserProfile!,
                ),
              ),
              shape: const CircleBorder(),
              backgroundColor: AppColors.tartOrange,
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildDataField(BuildContext context, String label, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.tartOrange,
                fontFamily: 'Poppins',
              ),
        ),
        Text(
          data,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection(String? url) {
    return Container(
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
        child: (url == null)
            ? Image.asset(
                Assets.imagesUserProfile,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl: url,
                imageBuilder: (context, imageProvider) {
                  return Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  );
                },
                errorWidget: (context, url, error) {
                  return Image.asset(
                    Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
    );
  }
}
