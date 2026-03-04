// lib/main.dart

import 'package:application_meteo/ui/screens/animations/principal.dart';
import 'package:application_meteo/ui/screens/animations/transition.dart';
import 'package:application_meteo/ui/screens/detail/city_detail_screen.dart';
import 'package:application_meteo/ui/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // ProviderScope is required for Riverpod — wraps the entire app
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SplashScreen()),
    ),
    GoRoute(
      path: '/main',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MainScreen()),
    ),
    GoRoute(
      path: '/animations',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, String>;
        return NoTransitionPage(
          child: Trans1(
            cityName: data['cityName']!,
            temp: data['temp']!,
            condition: data['condition']!,
          ),
        );
      },
    ),
    GoRoute(
      path: '/detail',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, String>;
        return NoTransitionPage(
          child: CityDetailScreen(
            cityName: data['cityName']!,
            temp: data['temp']!,
            condition: data['condition']!,
          ),
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SenMéteo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
