import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../data/providers/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
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
      duration: const Duration(seconds: 3),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
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
      if (status == AnimationStatus.completed) context.go('/main');
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
    final isLight = ref.watch(themeProvider);  // ✅
    const double iconSize = 36.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isLight ? AppTheme.lightBg1 : const Color(0xFF1A0033),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny_rounded, size: 100, color: Colors.amber),
                const SizedBox(height: 24),
                Text(
                  'SenMeteo',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isLight ? AppTheme.lightText : Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre météo en temps réel',
                  style: TextStyle(
                    fontSize: 16,
                    color: isLight
                        ? AppTheme.lightText.withOpacity(0.65)
                        : Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_progressController, _cloudFloatController]),
                    builder: (context, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth;
                          final tipX = barWidth * _progressController.value;
                          final iconLeft =
                          (tipX - iconSize / 2).clamp(0.0, barWidth - iconSize);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: barWidth,
                                height: 50,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: iconLeft,
                                      top: 4 + _cloudFloat.value,
                                      child: Icon(
                                        Icons.cloud,
                                        size: iconSize,
                                        color: isLight
                                            ? AppTheme.lightBg2
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                children: [
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? AppTheme.lightBg2.withOpacity(0.2)
                                          : Colors.white24,
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
                                  style: TextStyle(
                                    color: isLight
                                        ? AppTheme.lightText.withOpacity(0.7)
                                        : Colors.white70,
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