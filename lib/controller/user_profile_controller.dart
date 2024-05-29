import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:chat_box/model/user_model.dart';
import 'package:chat_box/repositories/user_repository.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final _currentUserProfile = Rx<UserModel?>(null);
  final userRepository = UserRepository();

  final _isCreatingUserProfile = false.obs;

  final _isFetchingUserProfile = false.obs;

  final _isUpdatingUserProfile = false.obs;

  bool get isCreatingUserProfile => _isCreatingUserProfile.value;

  bool get isFetchingUserProfile => _isFetchingUserProfile.value;

  bool get isUpdatingUserProfile => _isUpdatingUserProfile.value;

  UserModel? get currentUserProfile => _currentUserProfile.value;

  StreamSubscription? userProfileSubscription;

  @override
  void onInit() {
    ever(_currentUserProfile, (user) {
      if (user != null) {
        if (Get.currentRoute == '/create_profile' ||
            Get.currentRoute == '/login') {
          Get.offNamed('/shell');
        }
      }
    });
    super.onInit();
  }

  Future<void> createUserProfile({
    required String email,
    required UserModel user,
    File? image,
  }) async {
    _isCreatingUserProfile.value = true;
    try {
      await userRepository.createUserProfile(
        email: email,
        user: user,
        image: image,
      );
      getUserProfile(email);
    } catch (e) {
      dev.log('Got error: $e', name: 'Profile');
    }
    _isCreatingUserProfile.value = false;
  }

  Future<void> updateUserProfile({
    required String email,
    required UserModel user,
    File? image,
    required bool removeProfilePhoto,
  }) async {
    _isUpdatingUserProfile.value = true;
    try {
      await userRepository.editUserProfile(
        email: email,
        user: user,
        image: image,
        removeImage: removeProfilePhoto,
      );
      Get.back();
      Get.snackbar('Profile', 'User profile updated successfully!');
    } catch (e) {
      dev.log('Got error: $e', name: 'Profile');
    }
    _isUpdatingUserProfile.value = false;
  }

  void getUserProfile(String email) {
    dev.log('Subscribing user to email: $email', name: 'Profile');
    userProfileSubscription = userRepository.getUserProfile(email).listen(
      (event) {
        dev.log('User data changed: $event');
        _currentUserProfile.value = event;
      },
    );
  }

  void closeSubscriptions() {
    _currentUserProfile.value = null;
    userProfileSubscription?.cancel();
  }
}
