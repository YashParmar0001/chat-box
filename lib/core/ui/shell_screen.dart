import 'package:chat_box/constants/colors.dart';
import 'package:chat_box/features/home/screens/home_screen.dart';
import 'package:chat_box/features/profile/screens/my_profile_screen.dart';
import 'package:chat_box/generated/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      HomeScreen(),
      MyProfileScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 1,
              color: Colors.black26,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(0, Assets.iconsHome),
            // FloatingActionButton.extended(
            //   onPressed: () {},
            //   label: Text(
            //     'New Chat',
            //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //           fontFamily: 'Poppins',
            //           color: Colors.white,
            //         ),
            //   ),
            //   icon: const Icon(
            //     Icons.add,
            //     color: Colors.white,
            //   ),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30),
            //   ),
            //   backgroundColor: AppColors.tartOrange,
            // ),
            _buildItem(1, Assets.iconsUser),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int index, String asset) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_index != index) _index = index;
        });
      },
      child: SvgPicture.asset(
        asset,
        width: 30,
        color: (_index == index) ? Colors.black : Colors.grey,
      ),
    );
  }
}
