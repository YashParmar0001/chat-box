import 'package:chat_box/binding.dart';
import 'package:chat_box/constants/app_theme.dart';
import 'package:chat_box/core/ui/shell_screen.dart';
import 'package:chat_box/features/auth/screens/create_profile_screen.dart';
import 'package:chat_box/features/auth/screens/login_screen.dart';
import 'package:chat_box/features/splash/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat Box',
      theme: AppTheme.getTheme(),
      initialBinding: ChatBoxBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => const LogInScreen(),
        ),
        GetPage(
          name: '/create_profile',
          page: () => const CreateProfileScreen(),
        ),
        GetPage(
          name: '/shell',
          page: () => const ShellScreen(),
        )
      ],
    );
  }
}
