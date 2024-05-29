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

  Future<void> blockUser(String userId) async {
    final email = Get.find<AuthController>().email;
    await userRepository.blockUser(email!, userId);
    Get.snackbar('User', 'User is blocked!');
  }

  Future<void> unblockUser(String userId) async {
    final email = Get.find<AuthController>().email;
    await userRepository.unblockUser(email!, userId);
    Get.snackbar('User', 'User is Unblocked!');
  }
}
