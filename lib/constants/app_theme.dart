import 'package:chat_box/constants/texts.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: AppColors.tartOrange,
      textTheme: const TextTheme(
        displayLarge: AppTexts.displayLarge,
        displayMedium: AppTexts.displayMedium,
        displaySmall: AppTexts.displaySmall,
        headlineMedium: AppTexts.headlineMedium,
        headlineSmall: AppTexts.headlineSmall,
        titleLarge: AppTexts.titleLarge,
        titleMedium: AppTexts.titleMedium,
        bodySmall: AppTexts.bodySmall,
      ),
    );
  }
}