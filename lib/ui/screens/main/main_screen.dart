// lib/ui/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../widgets/weather_card_item.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _sliderTimer;

  double _jaugeProgress = 0.0;
  bool _isJaugeComplete = false;
  Timer? _jaugeTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _startJaugeCycle();
  }

  void _startJaugeCycle() {
    _jaugeTimer?.cancel();
    _jaugeProgress = 0.0;
    _isJaugeComplete = false;

    _jaugeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (!_isJaugeComplete) {
          if (_jaugeProgress < 1.0) {
            _jaugeProgress += 0.015;
          } else {
            _isJaugeComplete = true;

            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _isJaugeComplete) {
                setState(() {
                  _startJaugeCycle();
                });
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _jaugeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.bgDeep, Color(0xFF2D0054)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildMainCard(),
                  const SizedBox(height: 30),
                  _buildDetailsRow(),
                  const SizedBox(height: 30),
                  const Text(
                    "Autres villes",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const WeatherCardItem(cityName: "Dakar", temp: "22", condition: "Ensoleillé"),
                  const WeatherCardItem(cityName: "Paris", temp: "14", condition: "Brumeux"),
                  const WeatherCardItem(cityName: "Tokyo", temp: "28", condition: "Beau temps"),
                  const WeatherCardItem(cityName: "London", temp: "06", condition: "Froid"),
                  const WeatherCardItem(cityName: "Hong Kong", temp: "-5", condition: "Enneigée"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SenMeteo", style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Jeudi, 5 Mars 22:00", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        IconButton(icon: const Icon(Icons.sunny, color: Colors.yellow), onPressed: () {}),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: PageView(
          controller: _pageController,
          onPageChanged: (int page) => setState(() => _currentPage = page),
          children: [
            _buildSlideContent(title: "22°", subtitle: "Ciel ouvert", icon: Icons.wb_sunny_rounded, iconColor: Colors.amber),
            _buildSlideContent(title: "30%", subtitle: "Risque de pluie", icon: Icons.umbrella_rounded, iconColor: Colors.blueAccent),
            _buildSlideContent(title: "AQI 12", subtitle: "Qualité de l'air", icon: Icons.air_rounded, iconColor: Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent({required String title, required String subtitle, required IconData icon, required Color iconColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(subtitle, style: const TextStyle(fontSize: 20, color: AppTheme.accentPurple, fontWeight: FontWeight.w500)),
        const SizedBox(height: 25),

        // ZONE INTERACTIVE : JAUGE <-> BOUTON
        SizedBox(
          height: 50,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
            },
            child: _isJaugeComplete
                ? ElevatedButton.icon(
              key: const ValueKey('btn'),
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text("Recommencer", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            )
                : Container(
              key: const ValueKey('jauge'),
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _jaugeProgress,
                      backgroundColor: Colors.white10,
                      color: Colors.amber,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Chargement...", style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Icon(icon, color: iconColor.withOpacity(0.7), size: 30),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.water_drop, "30%", "Précipitation"),
          _infoItem(Icons.opacity, "20%", "Humidité"),
          _infoItem(Icons.air, "12 km/h", "Vent"),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}