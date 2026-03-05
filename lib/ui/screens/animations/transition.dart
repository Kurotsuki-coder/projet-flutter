import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../data/providers/theme_provider.dart';

class Trans1 extends ConsumerStatefulWidget {
  final String cityName;
  final String temp;
  final String condition;

  const Trans1({
    super.key,
    required this.cityName,
    required this.temp,
    required this.condition,
  });

  @override
  ConsumerState<Trans1> createState() => _TransScreenState();
}

class _TransScreenState extends ConsumerState<Trans1>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.pushReplacement('/detail', extra: {
          'cityName': widget.cityName,
          'temp': widget.temp,
          'condition': widget.condition,
        });
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
    final isLight = ref.watch(themeProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    const double paddingHorizontal = 30;
    const double planeSize = 48.0;
    const double barHeight = 16;
    const double spacing = 8;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isLight ? AppTheme.lightBg1 : const Color(0xFF1A0033),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  final double barWidth = screenWidth - paddingHorizontal * 2;
                  final double planeLeft =
                  (_progressController.value * barWidth - planeSize / 2)
                      .clamp(0.0, barWidth - planeSize);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Dakar ➝ ${widget.cityName}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isLight ? AppTheme.lightText : Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 60),
                      SizedBox(
                        height: planeSize + spacing + barHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isLight
                                      ? AppTheme.lightBg2.withOpacity(0.2)
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0, left: 0,
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
                            Positioned(
                              left: planeLeft, top: 0,
                              child: Transform.rotate(
                                angle: pi / 2,
                                child: Icon(
                                  Icons.flight,
                                  size: planeSize,
                                  color: isLight ? AppTheme.lightBg2 : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Destination',
                              style: TextStyle(
                                color: isLight
                                    ? AppTheme.lightText.withOpacity(0.65)
                                    : Colors.white70,
                                fontSize: 16,
                              )),
                          Text(widget.cityName,
                              style: TextStyle(
                                color: isLight
                                    ? AppTheme.lightText.withOpacity(0.65)
                                    : Colors.white70,
                                fontSize: 16,
                              )),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '${(_progressController.value * 100).toInt()}%',
                        style: TextStyle(
                          color: isLight ? AppTheme.lightText : Colors.white,
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