import 'package:application_meteo/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:application_meteo/core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.bgDeep, Color(0xFF2D0054), AppTheme.bgDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                  const Icon(
                    Icons.cloud_outlined,
                    size: 180,
                    color: Colors.white,
                  ),
                  Positioned(
                    bottom: 20,
                    child: Row(
                      children: List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.water_drop_sharp, color: Colors.blueAccent, size: 30),
                      )),
                    ),
                  )
                ],
              ),

            const SizedBox(height: 40),

            const Text(
              "SenMeteo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Découvrer la météo de vos villes préférées avec une expérience immersive unique.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: ElevatedButton(
                onPressed: () => context.push('/splash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 15,
                  shadowColor: AppTheme.accentPurple.withOpacity(0.5),
                ),
                child: const Text(
                  "Commencer l'expérience",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
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
  const PositionPoint({
    super.key,
    this.top,
    this.right,
    required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: child,
    );
  }
}
