import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchUsersController extends GetxController {
  final _searchApplied = false.obs;

  bool get searchApplied => _searchApplied.value;

  final searchTextController = TextEditingController();

  final _resultUsers = <UserModel>[].obs;

  List<UserModel> get resultUsers => _resultUsers;

  final usersController = Get.find<ChatController>();

  @override
  void onInit() {
    searchTextController.addListener(() {
      _resultUsers.value = usersController.users
          .where((e) => e.name.contains(searchTextController.text.trim()))
          .toList();
    });
    super.onInit();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  void clearSearch() {
    _searchApplied.value = false;
    searchTextController.clear();
  }
}
