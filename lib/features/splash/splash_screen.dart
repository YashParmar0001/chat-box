import 'package:chat_box/constants/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 48,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'box',
                  style: TextStyle(
                    fontSize: 48,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColors.tartOrange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(color: AppColors.tartOrange,),
          ],
        ),
      ),
    );
  }
}
