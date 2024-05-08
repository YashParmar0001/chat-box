import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    required this.controller,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.tartOrange,
                fontFamily: 'Poppins',
              ),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.tartOrange),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0,
            ),
          ),
          cursorColor: AppColors.tartOrange,
          style: Theme.of(context).textTheme.headlineSmall,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
        ),
      ],
    );
  }
}
