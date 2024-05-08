import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:get/get.dart';

class ChatBoxBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}