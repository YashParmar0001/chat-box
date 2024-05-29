import 'package:flutter/material.dart';


class FilledIconButton extends StatelessWidget {
  const FilledIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.backgroundColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: backgroundColor,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
