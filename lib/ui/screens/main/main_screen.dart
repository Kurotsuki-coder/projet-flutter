import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/providers/weather_providers.dart';
import '../../../data/providers/theme_provider.dart';
import '../../widgets/weather_card_item.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _sliderTimer;

  double _jaugeProgress = 0.0;
  bool _isJaugeComplete = false;
  Timer? _jaugeTimer;

  int _messageIndex = 0;
  final List<String> _loadingMessages = [
    'Nous téléchargeons les données…',
    'C\'est presque fini…',
    'Plus que quelques secondes…',
  ];
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_currentPage + 1) % 3;
      setState(() => _currentPage = next);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _startJaugeCycle();
  }

  void _startJaugeCycle() {
    _jaugeTimer?.cancel();
    _messageTimer?.cancel();
    setState(() {
      _jaugeProgress = 0.0;
      _isJaugeComplete = false;
      _messageIndex = 0;
    });

    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isJaugeComplete && mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _loadingMessages.length);
      }
    });

    _jaugeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        if (_jaugeProgress < 1.0) {
          _jaugeProgress += 0.015;
        } else {
          _isJaugeComplete = true;
          timer.cancel();
          _messageTimer?.cancel();
        }
      });
    });
  }

  void _restart() {
    ref.invalidate(allCitiesWeatherProvider);
    _startJaugeCycle();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _jaugeTimer?.cancel();
    _messageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(allCitiesWeatherProvider);
    final isLight = ref.watch(themeProvider);

    final bgGradient = isLight
        ? const LinearGradient(
      colors: [AppTheme.lightBg1, AppTheme.lightBg3],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    )
        : const LinearGradient(
      colors: [AppTheme.bgDeep, Color(0xFF2D0054)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final scaffoldBg = isLight ? AppTheme.lightBg1 : AppTheme.bgDeep;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(isLight),
                  const SizedBox(height: 30),
                  _buildMainCard(isLight),
                  const SizedBox(height: 30),
                  _buildDetailsRow(isLight),
                  const SizedBox(height: 30),
                  Text(
                    'Autres villes',
                    style: TextStyle(
                      color: isLight ? AppTheme.lightText : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCityList(weatherAsync, isLight),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── City list ─────────────────────────────────────────────────────────────

  Widget _buildCityList(AsyncValue weatherAsync, bool isLight) {
    return weatherAsync.when(
      loading: () => _buildLoadingList(isLight),
      error: (err, _) => _buildErrorWidget(err.toString(), isLight),
      data: (results) {
        if (!_isJaugeComplete) return _buildLoadingList(isLight);
        return _buildResultList(results, isLight); // ← isLight ajouté
      },
    );
  }

  Widget _buildLoadingList(bool isLight) {
    return Column(
      children: List.generate(
        5,
            (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: isLight
                ? AppTheme.lightBg2.withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultList(List results, bool isLight) {
    final widgets = <Widget>[];
    for (final either in results) {
      either.fold(
            (failure) => widgets.add(_buildFailureCard(failure.message)),
            (model) => widgets.add(
          WeatherCardItem.fromModel(model as WeatherModel, isLight: isLight),
        ),
      );
    }
    return Column(children: widgets);
  }

  Widget _buildFailureCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _restart,
            child: const Text('Réessayer',
                style: TextStyle(color: AppTheme.accentPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight ? AppTheme.lightText : Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isLight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SenMeteo',
              style: TextStyle(
                color: isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _formattedDate(),
              style: TextStyle(
                color: isLight ? AppTheme.lightText.withOpacity(0.6) : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        // ── Bouton toggle dark/light ──────────────────────────────────────────
        GestureDetector(
          onTap: () => ref.read(themeProvider.notifier).toggle(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLight
                  ? AppTheme.lightBg2.withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLight ? Icons.dark_mode_rounded : Icons.sunny,
              color: isLight ? AppTheme.lightBg2 : Colors.yellow,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}  '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ─── Main Card ─────────────────────────────────────────────────────────────

  Widget _buildMainCard(bool isLight) {
    final weatherAsync = ref.watch(allCitiesWeatherProvider);

    WeatherModel? firstCity;
    weatherAsync.whenData((results) {
      if (results.isNotEmpty) {
        results.first.fold((_) {}, (model) => firstCity = model as WeatherModel);
      }
    });

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLight
            ? AppTheme.lightBg2.withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isLight
              ? AppTheme.lightBg2.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: PageView(
          controller: _pageController,
          onPageChanged: (p) => setState(() => _currentPage = p),
          children: [
            _buildSlideContent(
              title: firstCity != null ? firstCity!.tempDisplay : '—°',
              subtitle: firstCity != null ? firstCity!.description : 'Chargement…',
              icon: Icons.wb_sunny_rounded,
              iconColor: Colors.amber,
              isLight: isLight,
            ),
            _buildSlideContent(
              title: firstCity != null ? '${firstCity!.humidity}%' : '—%',
              subtitle: 'Humidité',
              icon: Icons.water_drop_rounded,
              iconColor: Colors.blueAccent,
              isLight: isLight,
            ),
            _buildSlideContent(
              title: firstCity != null
                  ? '${firstCity!.windSpeed.toStringAsFixed(1)} m/s'
                  : '— m/s',
              subtitle: 'Vitesse du vent',
              icon: Icons.air_rounded,
              iconColor: Colors.greenAccent,
              isLight: isLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isLight,
  }) {
    final titleColor = isLight ? AppTheme.lightText : Colors.white;
    final subtitleColor = isLight ? AppTheme.lightBg2 : AppTheme.accentPurple;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 60, fontWeight: FontWeight.bold, color: titleColor)),
        Text(subtitle,
            style: TextStyle(
                fontSize: 18, color: subtitleColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        SizedBox(
          height: 60,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: _isJaugeComplete
                ? ElevatedButton.icon(
              key: const ValueKey('btn'),
              onPressed: _restart,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Recommencer',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            )
                : Padding(
              key: const ValueKey('jauge'),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _jaugeProgress,
                      backgroundColor: isLight
                          ? AppTheme.lightBg2.withOpacity(0.2)
                          : Colors.white10,
                      color: isLight ? AppTheme.lightBg2 : Colors.amber,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _loadingMessages[_messageIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isLight
                          ? AppTheme.lightText.withOpacity(0.5)
                          : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Icon(icon, color: iconColor.withOpacity(0.7), size: 28),
      ],
    );
  }

  // ─── Details row ───────────────────────────────────────────────────────────

  Widget _buildDetailsRow(bool isLight) {
    final weatherAsync = ref.watch(allCitiesWeatherProvider);
    WeatherModel? first;
    weatherAsync.whenData((results) {
      if (results.isNotEmpty) {
        results.first.fold((_) {}, (m) => first = m as WeatherModel);
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isLight
            ? AppTheme.lightBg2.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.water_drop, '${first?.cloudiness ?? '—'}%', 'Nuages', isLight),
          _infoItem(Icons.opacity, '${first?.humidity ?? '—'}%', 'Humidité', isLight),
          _infoItem(Icons.air,
              first != null ? '${first!.windSpeed.toStringAsFixed(1)} m/s' : '—',
              'Vent', isLight),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label, bool isLight) {
    return Column(
      children: [
        Icon(icon,
            color: isLight ? AppTheme.lightBg2 : Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: isLight ? AppTheme.lightText : Colors.white,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: isLight
                    ? AppTheme.lightText.withOpacity(0.5)
                    : Colors.white54,
                fontSize: 10)),
      ],
    );
  }
}