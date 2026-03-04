import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDeep = Color(0xFF1A0033);
  static const Color accentPurple = Color(0xFFC77DFF);
  static const Color skyBlue = Color(0xFF37B7BF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: bgDeep,
    colorScheme: ColorScheme.light(
      primary: bgDeep,
      secondary: accentPurple,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    primaryColor: accentPurple,
    colorScheme: ColorScheme.dark(
      primary: accentPurple,
      secondary: skyBlue,
    ),
  );
}