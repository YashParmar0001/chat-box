import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/features/groups/screens/groups_screen.dart';
import 'package:chat_box/features/home/screens/home_screen.dart';
import 'package:chat_box/features/profile/screens/my_profile_screen.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authController = Get.find<AuthController>();

    switch (state) {
      case AppLifecycleState.resumed:
        authController.setUserState(true);
        break;
      case AppLifecycleState.paused:
        authController.setUserState(false);
        break;
      case AppLifecycleState.inactive:
        authController.setUserState(false);
        break;
      case AppLifecycleState.detached:
        authController.setUserState(false);
        break;
      case AppLifecycleState.hidden:
        authController.setUserState(false);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    const screens = [
      HomeScreen(),
      GroupsScreen(),
      MyProfileScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        fixedColor: AppColors.myrtleGreen,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'Caros',
        ),
        currentIndex: _index,
        elevation: 10,
        items: [
          _buildItem(
            index: 0,
            icon: Assets.iconsMessages,
            label: 'Messages',
          ),
          _buildItem(
            index: 1,
            icon: Assets.iconsUserGroup,
            label: 'Groups',
          ),
          _buildItem(
            index: 2,
            icon: Assets.iconsUser,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({
    required String icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(
        icon,
        color: Colors.grey,
      ),
      activeIcon: SvgPicture.asset(
        icon,
        color: AppColors.myrtleGreen,
      ),
    );
  }
}
