import 'dart:math';
import 'package:flutter/material.dart';

class Trans1 extends StatefulWidget {
  const Trans1({super.key});

  @override
  State<Trans1> createState() => _TransScreenState();
}

class _TransScreenState extends State<Trans1> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _angleAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _angleAnimation = Tween<double>(
      begin: pi / 2,
      end: pi / 2,
    ).animate(_progressController);

    _fadeController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double paddingHorizontal = 30;
    const double planeSize = 48.0;
    const double barHeight = 16;
    const double spacing = 8;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0033),
              Color(0xFF7B2FBE),
              Color(0xFFC77DFF),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  final double barWidth =
                      screenWidth - paddingHorizontal * 2;

                  final double planeLeft =
                  (_progressController.value * barWidth - planeSize / 2)
                      .clamp(0.0, barWidth - planeSize);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Dakar ➝ Paris",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // BARRE + AVION
                      SizedBox(
                        height: planeSize + spacing + barHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Barre de fond
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),

                            // Barre amber animée
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: barWidth * _progressController.value,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Avion incliné au décollage
                            Positioned(
                              left: planeLeft,
                              top: 0,
                              child: Transform.rotate(
                                angle: _angleAnimation.value,
                                child: const Icon(
                                  Icons.flight,
                                  size: planeSize,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Villes
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dakar",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Paris",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Pourcentage
                      Text(
                        "${(_progressController.value * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Bienvenue à Paris ✈️",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}