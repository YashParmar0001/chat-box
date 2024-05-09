import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/current_chat_controller.dart';
import 'package:chat_box/features/home/screens/chat_screen.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
      body: Obx(
        () {
          if (chatController.isLoading) {
            return const CircularProgressIndicator(
              color: AppColors.tartOrange,
            );
          } else {
            return ListView.builder(
              itemCount: chatController.users.length,
              itemBuilder: (context, index) {
                final user = chatController.users[index];
                return _Chat(user: user);
              },
            );
          }
        },
      ),
    );
  }
}

class _Chat extends StatelessWidget {
  const _Chat({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => ChatScreen(
          user: user,
          chatController: Get.put(
            CurrentChatController2(
              currentUserId: Get.find<AuthController>().email!,
              otherUserId: user.email,
            ),
            // CurrentChatController(
            //   currentUserId: Get.find<AuthController>().email!,
            //   otherUserId: user.email,
            // ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: user.profilePicUrl ?? '',
              placeholder: (context, url) {
                return ClipOval(
                  child: Image.asset(
                    Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                return ClipOval(
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return ClipOval(
                  child: Image.asset(
                    Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                // const SizedBox(height: 5),
                // Text(
                //   'What about today?',
                //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
            // const Spacer(),
            // Text(
            //   '2 min ago',
            //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //     color: Colors.grey,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
