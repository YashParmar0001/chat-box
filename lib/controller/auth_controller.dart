import 'dart:developer' as dev;

import 'package:chat_box/controller/user_profile_controller.dart';
import 'package:chat_box/core/ui/shell_screen.dart';
import 'package:chat_box/features/auth/screens/create_profile_screen.dart';
import 'package:chat_box/features/auth/screens/login_screen.dart';
import 'package:chat_box/repositories/auth_repository.dart';
import 'package:get/get.dart';

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
    // final userProfileController = Get.find<UserProfileController>();
    ever(_isAuthenticated, (isAuthenticated) {
      dev.log('Listen to auth states', name: 'Auth');
      if (!isAuthenticated) {
        dev.log('User logged out', name: 'Auth');
        _email.value = null;
        userProfileController.closeSubscriptions();
        Get.off(() => const LogInScreen());
      }
    });
    final isAuthenticated = await checkIsAuthenticated();
    if (isAuthenticated) {
      userProfileController.getUserProfile(email!);
      Get.off(() => const ShellScreen());
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
      Get.off(() => const CreateProfileScreen());
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
    }else {
      _isAuthenticated.value = true;
      _email.value = email;
      Get.find<UserProfileController>().getUserProfile(email);
      Get.off(() => const ShellScreen());
    }
    _isLoggingIn.value = false;
  }

  Future<void> logout() async {
    final result = await _authRepository.logout();
    if (!result) {
      Get.snackbar('Log Out', 'Something went wrong!');
    }else {
      _isAuthenticated.value = false;
      dev.log('Logged out user: ${_isAuthenticated.value}', name: 'Auth');
    }
  }

  Future<bool> checkIsAuthenticated() async {
    _isAuthenticated.value = await _authRepository.isLoggedIn();
    if (_isAuthenticated.value) {
      _email.value = _authRepository.getEmail();
    }
    return _isAuthenticated.value;
  }
}
