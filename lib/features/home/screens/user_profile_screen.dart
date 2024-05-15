import 'package:chat_box/core/ui/profile_photo.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                ProfilePhoto(url: user.profilePicUrl),
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
              user.email,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataField(BuildContext context, String label, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.tartOrange,
                fontFamily: 'Poppins',
              ),
        ),
        Text(
          data,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
