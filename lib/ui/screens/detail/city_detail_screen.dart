// lib/ui/screens/detail/city_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/providers/weather_providers.dart';

class CityDetailScreen extends ConsumerWidget {
  final String cityName;
  final String temp;
  final String condition;

  const CityDetailScreen({
    super.key,
    required this.cityName,
    required this.temp,
    required this.condition,
  });

  // Fallback coordinates (used until API responds)
  static const Map<String, LatLng> _fallbackCoords = {
    'Dakar': LatLng(14.7167, -17.4677),
    'Paris': LatLng(48.8566, 2.3522),
    'Tokyo': LatLng(35.6895, 139.6917),
    'London': LatLng(51.5074, -0.1278),
    'Hong Kong': LatLng(22.3193, 114.1694),
  };

  static const List<Map<String, dynamic>> _forecast = [
    {'day': 'Lun', 'condition': 'Ciel ouvert',       'high': '20', 'low': '16', 'icon': Icons.wb_sunny_rounded},
    {'day': 'Mar', 'condition': 'Brouillard',         'high': '19', 'low': '15', 'icon': Icons.cloud_rounded},
    {'day': 'Mer', 'condition': 'Partiellement clair','high': '21', 'low': '17', 'icon': Icons.wb_cloudy_rounded},
    {'day': 'Jeu', 'condition': 'Ensoleillé',         'high': '22', 'low': '18', 'icon': Icons.wb_sunny_rounded},
    {'day': 'Ven', 'condition': 'Averses',            'high': '17', 'low': '13', 'icon': Icons.grain_rounded},
    {'day': 'Sam', 'condition': 'Nuageux',            'high': '19', 'low': '15', 'icon': Icons.cloud_outlined},
    {'day': 'Dim', 'condition': 'Orages',             'high': '18', 'low': '14', 'icon': Icons.thunderstorm_rounded},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live data for this specific city
    final weatherAsync = ref.watch(singleCityWeatherProvider(cityName));

    return weatherAsync.when(
      loading: () => _buildScaffold(context, null, isLoading: true),
      error: (err, _) => _buildScaffold(context, null, errorMsg: err.toString()),
      data: (either) => either.fold(
        (failure) => _buildScaffold(context, null, errorMsg: failure.message),
        (model) => _buildScaffold(context, model as WeatherModel),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WeatherModel? model, {
    bool isLoading = false,
    String? errorMsg,
  }) {
    final fallback = _fallbackCoords[cityName] ?? const LatLng(14.7167, -17.4677);
    final cityPos = model != null
        ? LatLng(model.latitude, model.longitude)
        : fallback;

    final displayTemp = model?.tempDisplay ?? '$temp°';
    final displayCondition = model?.description ?? condition;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.bgDeep, Color(0xFF2D0054)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 22),
                      onPressed: () => context.go('/main'),
                    ),
                    Expanded(
                      child: Text(
                        cityName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // ── Error banner ─────────────────────────────────────────────
            if (errorMsg != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(errorMsg,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // ── Map ───────────────────────────────────────────────────────
            Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: cityPos,
                    initialZoom: 11.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.application_meteo',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: cityPos,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Current weather summary ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.accentPurple),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$displayTemp  •  $displayCondition',
                          style: const TextStyle(
                              color: AppTheme.accentPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        if (model != null)
                          Text(
                            '💧${model.humidity}%  🌬${model.windSpeed.toStringAsFixed(1)}m/s',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                      ],
                    ),
            ),

            // ── Live weather details row ───────────────────────────────────
            if (model != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _detailChip(Icons.thermostat_rounded,
                          'Ressenti', '${model.feelsLike.toStringAsFixed(0)}°'),
                      _detailChip(Icons.compress_rounded,
                          'Pression', '${model.pressure} hPa'),
                      _detailChip(Icons.visibility_rounded,
                          'Visibilité', '${(model.visibility / 1000).toStringAsFixed(0)} km'),
                    ],
                  ),
                ),
              ),

            // ── Forecast header ───────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Prévisions 7 jours',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ── Forecast list ─────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _forecast.length,
                itemBuilder: (context, i) {
                  final item = _forecast[i];
                  return _ForecastRow(
                    day: item['day'],
                    condition: item['condition'],
                    high: item['high'],
                    low: item['low'],
                    icon: item['icon'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentPurple, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final String day, condition, high, low;
  final IconData icon;

  const _ForecastRow({
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(day,
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          Icon(icon, color: Colors.amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(condition,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
          Text('$high°',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('$low°',
              style: const TextStyle(
                  color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}
