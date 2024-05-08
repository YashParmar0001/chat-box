import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/constants/string_constants.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/core/ui/custom_text_field.dart';
import 'package:chat_box/core/ui/primary_button.dart';
import 'package:chat_box/features/auth/screens/login_screen.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                SvgPicture.asset(
                  Assets.artLogin,
                  width: 200,
                ),
                const SizedBox(height: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sign Up to Chat',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'box',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.tartOrange,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      StringConstants.signUpDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: emailController,
                  label: 'Your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: passwordController,
                  label: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm password',
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                Obx(() {
                  if (authController.isSigningUp) {
                    return const CircularProgressIndicator(
                      color: AppColors.tartOrange,
                    );
                  }else {
                    return Column(
                      children: [
                        PrimaryButton(
                          onPressed: () {
                            if (passwordController.text ==
                                confirmPasswordController.text) {
                              Get.find<AuthController>().signUp(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            } else {
                              Get.snackbar(
                                'Warning',
                                'Password and Confirm password should be the same!',
                              );
                            }
                          },
                          title: 'Sign Up',
                        ),
                      ],
                    );
                  }
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.off(() => const LogInScreen());
                      },
                      child: Text(
                        'Log In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Poppins',
                              color: AppColors.tartOrange,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
