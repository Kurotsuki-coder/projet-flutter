import 'package:flutter/material.dart';
import 'package:meteo/screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _cloudFloatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _cloudFloat;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    // Cloud vertical float animation (looping)
    _cloudFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _cloudFloat = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _cloudFloatController, curve: Curves.easeInOut),
    );

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
    _cloudFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Taille de l'icône cloud (pour centrage)
    const double iconSize = 36.0;

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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wb_sunny_rounded,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),
                const Text(
                  'WeatherApp',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre meteo en temps reel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),

                // ── Progress bar + icône cloud ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _progressController,
                      _cloudFloatController,
                    ]),
                    builder: (context, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth;

                          // Position X de la pointe de la barre
                          final tipX = barWidth * _progressController.value;

                          // L'icône est centrée sur la pointe, clampée dans la barre
                          final iconLeft =
                          (tipX - iconSize / 2).clamp(0.0, barWidth - iconSize);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Zone au-dessus de la barre avec l'icône cloud
                              SizedBox(
                                width: barWidth,
                                height: 50,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: iconLeft,
                                      // Float vertical + centré verticalement
                                      top: 4 + _cloudFloat.value,
                                      child: const Icon(
                                        Icons.cloud,
                                        size: iconSize,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Barre de progression
                              Stack(
                                children: [
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: _progressController.value,
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: Text(
                                  '${(_progressController.value * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}