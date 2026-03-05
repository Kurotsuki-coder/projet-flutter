import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(_isDay());

  static bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 7 && hour < 19;
  }

  void toggle() => state = !state;
}