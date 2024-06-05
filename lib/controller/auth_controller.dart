import 'dart:developer' as dev;

import 'package:chat_box/controller/groups_controller.dart';
import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../core/listeners/notification_click_listener.dart';

class AuthController extends GetxController {
  final _authRepository = AuthRepository();

  final _isAuthenticated = false.obs;
  final _email = Rx<String?>(null);

  bool get isAuthenticated => _isAuthenticated.value;

  final _isLoggingIn = false.obs;
  final _isSigningUp = false.obs;

  String? get email => _email.value;

  bool get isLoggingIn => _isLoggingIn.value;

  bool get isSigningUp => _isSigningUp.value;

  @override
  Future<void> onInit() async {
    final userProfileController = Get.put(UserProfileController());
    final groupsController = Get.put(GroupsController());

    ever(_isAuthenticated, (isAuthenticated) async {
      if (!isAuthenticated) {
        setUserState(false, email: email);
        _email.value = null;
        userProfileController.closeSubscriptions();
        groupsController.closeSubscriptions();
        await OneSignal.logout();
        Get.back();
        Get.back();
        Get.offNamed('/login');
      } else {
        setUserState(true, email: email);
        if (email != null) {
          groupsController.getGroups();
          // OneSignal.login(email!);
        }
      }
    });
    final isAuthenticated = await checkIsAuthenticated();
    if (isAuthenticated) {
      dev.log('User is authenticated', name: 'Notifications');
      OneSignal.Notifications.addClickListener(notificationClickListener);
      userProfileController.getUserProfile(email!);
      groupsController.getGroups();
      OneSignal.login(email!);
      Get.offNamed('/shell');
    }
    super.onInit();
  }

  Future<void> signUp({required String email, required String password}) async {
    _isSigningUp.value = true;
    final result = await _authRepository.signUp(
      email: email,
      password: password,
    );
    _isSigningUp.value = false;
    if (result) {
      _isAuthenticated.value = true;
      _email.value = email;
      Get.offNamed('/create_profile');
      Get.snackbar('Sign Up', 'Successfully signed up!');
    } else {
      _isAuthenticated.value = false;
      Get.snackbar('Sign Up', 'Something went wrong!');
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoggingIn.value = true;

    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    if (!result) {
      Get.snackbar('Sign Up', 'Something went wrong!');
      _isAuthenticated.value = false;
    } else {
      _isAuthenticated.value = true;
      _email.value = email;
      OneSignal.Notifications.addClickListener(notificationClickListener);
      Get.find<UserProfileController>().getUserProfile(email);
      Get.find<GroupsController>().getGroups();
      OneSignal.login(email);
      Get.offNamed('/shell');
    }
    _isLoggingIn.value = false;
  }

  Future<void> logout() async {
    final result = await _authRepository.logout();
    if (!result) {
      Get.snackbar('Log Out', 'Something went wrong!');
    } else {
      _isAuthenticated.value = false;
      dev.log('Logged out user Email: $email', name: 'Auth');
    }
  }

  Future<bool> checkIsAuthenticated() async {
    _isAuthenticated.value = await _authRepository.isLoggedIn();
    if (_isAuthenticated.value) {
      _email.value = _authRepository.getEmail();
    }
    return _isAuthenticated.value;
  }

  void setUserState(bool isOnline, {String? email}) {
    _authRepository.setUserState(isOnline, email: email);
  }
}
