import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Obx(
              () {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Auto Download Media',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Switch(
                      value: settingsController.autoDownload,
                      onChanged: (value) {
                        settingsController.setAutoDownload(value);
                      },
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () => _showLogoutConfirmationDialog(context, authController),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red),
              const SizedBox(width: 10),
              Text(
                'Log Out',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(
    BuildContext context,
    AuthController authController,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: authController.logout,
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
