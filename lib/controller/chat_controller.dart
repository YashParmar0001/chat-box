import 'dart:async';

import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/model/user_model.dart';
import 'package:chat_box/repositories/user_repository.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final _users = <UserModel>[].obs;

  List<UserModel> get users => _users;

  final _isLoading = true.obs;

  bool get isLoading => _isLoading.value;

  StreamSubscription? usersSubscription;

  final userRepository = UserRepository();

  @override
  void onInit() {
    usersSubscription = userRepository.getUsers().listen(
      (event) {
        _users.value = event;
        _isLoading.value = false;
      },
    );
    super.onInit();
  }

  void blockUser(String userId) {
    final email = Get.find<AuthController>().email;
    userRepository.blockUser(email!, userId);
  }

  void unblockUser(String userId) {
    final email = Get.find<AuthController>().email;
    userRepository.unblockUser(email!, userId);
  }
}
