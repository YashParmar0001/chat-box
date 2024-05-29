import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/current_chat_controller.dart';
import '../../../generated/assets.dart';
import '../../../model/user_model.dart';
import '../screens/chat_screen.dart';

class Chat extends StatelessWidget {
  const Chat({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isCurrentUser = authController.email! == user.email;

    return InkWell(
      onTap: () => Get.to(
        () => ChatScreen(
          userId: user.email,
          chatController: Get.put(
            CurrentChatController(
              currentUserId: authController.email!,
              otherUserId: user.email,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
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
                    if (user.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentUser ? 'You' : user.name,
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
            const SizedBox(height: 10),
            Container(
              color: Colors.grey,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
