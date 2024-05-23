import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/core/ui/profile_photo.dart';
import 'package:chat_box/features/profile/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userProfileController = Get.find<UserProfileController>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: authController.logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (userProfileController.isFetchingUserProfile) {
            return const CircularProgressIndicator(
              color: AppColors.myrtleGreen,
            );
          } else {
            final user = userProfileController.currentUserProfile;
            if (user != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        const Spacer(),
                        Column(
                          children: [
                            ProfilePhoto(
                              url: user.profilePicUrl,
                              dimension: 100,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
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
                ),
              );
            } else {
              return const SizedBox();
            }
          }
        },
      ),
      floatingActionButton: (userProfileController.currentUserProfile != null)
          ? FloatingActionButton.extended(
              heroTag: 'edit_profile',
              onPressed: () => Get.to(
                () => EditProfileScreen(
                  user: userProfileController.currentUserProfile!,
                ),
              ),
              backgroundColor: AppColors.myrtleGreen,
              label: Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              icon: const Icon(
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          data,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
