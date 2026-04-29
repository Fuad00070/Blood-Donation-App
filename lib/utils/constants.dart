import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color secondaryRed = Color(0xFFFFEBEE);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color white = Colors.white;
}

class AppStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textGrey,
  );
}
