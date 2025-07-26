import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundColor,
    primaryColor: AppColors.buttonColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textColor),
      titleTextStyle: TextStyle(
        color: AppColors.textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.buttonColor,
      onPrimary: Colors.white,
      background: AppColors.backgroundColor,
      onBackground: AppColors.textColor,
      surface: AppColors.backgroundColor,
      onSurface: AppColors.textColor,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textColor),
      bodyLarge: TextStyle(color: AppColors.textColor),
      titleLarge: TextStyle(color: AppColors.textColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20, // <-- added this line
        ),
      ),
    ),
  );
}
