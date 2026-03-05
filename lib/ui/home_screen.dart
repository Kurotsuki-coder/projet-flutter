import 'package:application_meteo/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(themeProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isLight ? AppTheme.lightBg1 : AppTheme.bgDeep,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  PositionPoint(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      size: 100,
                      color: Colors.amber.withOpacity(0.8),
                    ),
                  ),
                  Icon(
                    Icons.cloud_outlined,
                    size: 180,
                    color: isLight ? AppTheme.lightBg2 : Colors.white,
                  ),
                  Positioned(
                    bottom: 20,
                    child: Row(
                      children: List.generate(
                        3,
                            (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.water_drop_sharp,
                              color: Colors.blueAccent, size: 30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'SenMeteo',
                style: TextStyle(
                  color: isLight ? AppTheme.lightText : Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Découvrez la météo de vos villes préférées avec une expérience immersive unique.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight
                        ? AppTheme.lightText.withOpacity(0.65)
                        : Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: ElevatedButton(
                  onPressed: () => context.push('/splash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 15,
                    shadowColor: AppTheme.lightBg2.withOpacity(0.5),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Commencer l'expérience",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PositionPoint extends StatelessWidget {
  final double? top, right;
  final Widget child;
  const PositionPoint({super.key, this.top, this.right, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, right: right, child: child);
  }
}