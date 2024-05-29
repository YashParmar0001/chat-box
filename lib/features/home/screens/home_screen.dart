import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/controller/search_users_controller.dart';
import 'package:chat_box/features/home/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = Get.put(SearchUsersController());
  bool search = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: search
            ? UserSearchBar(
                onSearch: (value) {

                },
                searchController: searchController.searchTextController,
              )
            : Text(
                'Home',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (search) {
                  search = false;
                  searchController.clearSearch();
                }else {
                  search = true;
                }
              });
            },
            icon: search
                ? const Icon(Icons.close)
                : const Icon(
                    Icons.search_outlined,
                  ),
          )
        ],
      ),
      body: Obx(
        () {
          if (chatController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.myrtleGreen,
              ),
            );
          } else {
            if (search) {
              return ListView.builder(
                itemCount: searchController.resultUsers.length,
                itemBuilder: (context, index) {
                  return Chat(user: searchController.resultUsers[index]);
                },
              );
            }else {
              return ListView.builder(
                itemCount: chatController.users.length,
                itemBuilder: (context, index) {
                  final user = chatController.users[index];
                  return Chat(user: user);
                },
              );
            }
          }
        },
      ),
    );
  }
}
