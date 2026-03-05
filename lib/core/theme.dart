import 'package:flutter/material.dart';

class AppTheme {
  // ── Dark mode colors ──────────────────────────────────────────────────────
  static const Color bgDeep       = Color(0xFF1A0033);
  static const Color accentPurple = Color(0xFFC77DFF);
  static const Color skyBlue      = Color(0xFF37B7BF);

  // ── Light mode colors (tes couleurs demandées) ────────────────────────────
  static const Color lightBg1     = Color(0xFFDCEEFC);
  static const Color lightBg2     = Color(0xFF5F9AFB);
  static const Color lightBg3     = Color(0xFFF1F9FB);
  static const Color lightText    = Color(0xFF1A0033);
  static const Color lightSubtext = Color(0xFF5F9AFB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg1,
    primaryColor: lightBg2,
    colorScheme: const ColorScheme.light(
      primary: lightBg2,
      secondary: lightBg3,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    primaryColor: accentPurple,
    colorScheme: const ColorScheme.dark(
      primary: accentPurple,
      secondary: skyBlue,
    ),
  );
}
