import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/chat_controller.dart';
import 'package:chat_box/services/sqlite_service.dart';
import 'package:get/get.dart';

class ChatBoxBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ChatController());
    Get.put(SqliteService());
  }
}