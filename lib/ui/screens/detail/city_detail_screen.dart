import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/providers/theme_provider.dart';
import '../../../data/providers/weather_providers.dart';

class CityDetailScreen extends ConsumerStatefulWidget {
  final String cityName;
  final String temp;
  final String condition;

  const CityDetailScreen({
    super.key,
    required this.cityName,
    required this.temp,
    required this.condition,
  });

  @override
  ConsumerState<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends ConsumerState<CityDetailScreen> {

  static const Map<String, LatLng> _fallbackCoords = {
    'Dakar':     LatLng(14.7167, -17.4677),
    'Paris':     LatLng(48.8566,   2.3522),
    'Tokyo':     LatLng(35.6895, 139.6917),
    'London':    LatLng(51.5074,  -0.1278),
    'Hong Kong': LatLng(22.3193, 114.1694),
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.invalidate(singleCityWeatherProvider(widget.cityName)));
  }

  static Map<String, dynamic> _iconFromCode(String code) {
    if (code.startsWith('01d')) {
      return {'icon': Icons.wb_sunny_rounded,      'color': const Color(0xFFFFD600)};
    } else if (code.startsWith('01n')) {
      return {'icon': Icons.nightlight_round,       'color': const Color(0xFF90CAF9)};
    } else if (code.startsWith('02d')) {
      return {'icon': Icons.wb_cloudy_rounded,      'color': const Color(0xFFFFCA28)};
    } else if (code.startsWith('02n')) {
      return {'icon': Icons.wb_cloudy_rounded,      'color': const Color(0xFF78909C)};
    } else if (code.startsWith('03')) {
      return {'icon': Icons.cloud_rounded,           'color': const Color(0xFFB0BEC5)};
    } else if (code.startsWith('04')) {
      return {'icon': Icons.cloud_rounded,           'color': const Color(0xFF607D8B)};
    } else if (code.startsWith('09')) {
      return {'icon': Icons.grain_rounded,           'color': const Color(0xFF42A5F5)};
    } else if (code.startsWith('10d')) {
      return {'icon': Icons.umbrella_rounded,        'color': const Color(0xFF1E88E5)};
    } else if (code.startsWith('10n')) {
      return {'icon': Icons.umbrella_rounded,        'color': const Color(0xFF1565C0)};
    } else if (code.startsWith('11')) {
      return {'icon': Icons.thunderstorm_rounded,    'color': const Color(0xFF7C4DFF)};
    } else if (code.startsWith('13')) {
      return {'icon': Icons.ac_unit_rounded,         'color': const Color(0xFF80DEEA)};
    } else if (code.startsWith('50')) {
      return {'icon': Icons.foggy,                   'color': const Color(0xFF90A4AE)};
    }
    return   {'icon': Icons.wb_sunny_rounded,        'color': const Color(0xFFFFD600)};
  }

  static List<Map<String, dynamic>> _buildForecast(WeatherModel model) {
    const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final today = DateTime.now().weekday - 1;

    return List.generate(7, (i) {
      final dayLabel = dayNames[(today + i) % 7];
      final high = (model.temperature + (i == 0 ? 0 : (i % 3 - 1) * 1.5))
          .toStringAsFixed(0);
      final low = (model.temperature - 4 + (i % 2) * 0.5)
          .toStringAsFixed(0);
      final iconData = _iconFromCode(model.icon);

      return {
        'day':       i == 0 ? 'Auj.' : dayLabel,
        'condition': i == 0 ? model.description : _conditionFromCode(model.icon),
        'high':      high,
        'low':       low,
        'icon':      iconData['icon'],
        'color':     iconData['color'],
      };
    });
  }

  static String _conditionFromCode(String code) {
    if (code.startsWith('01')) return 'Ciel dégagé';
    if (code.startsWith('02')) return 'Peu nuageux';
    if (code.startsWith('03')) return 'Nuageux';
    if (code.startsWith('04')) return 'Très nuageux';
    if (code.startsWith('09')) return 'Averses';
    if (code.startsWith('10')) return 'Pluie';
    if (code.startsWith('11')) return 'Orages';
    if (code.startsWith('13')) return 'Neige';
    if (code.startsWith('50')) return 'Brouillard';
    return 'Variable';
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(singleCityWeatherProvider(widget.cityName));
    final isLight = ref.watch(themeProvider);

    return weatherAsync.when(
      loading: () => _buildScaffold(context, null, isLight, isLoading: true),
      error:   (err, _) => _buildScaffold(context, null, isLight, errorMsg: err.toString()),
      data:    (either) => either.fold(
            (failure) => _buildScaffold(context, null, isLight, errorMsg: failure.message),
            (model)   => _buildScaffold(context, model as WeatherModel, isLight),
      ),
    );
  }

  Widget _buildScaffold(
      BuildContext context,
      WeatherModel? model,
      bool isLight, {
        bool isLoading = false,
        String? errorMsg,
      }) {
    final fallback = _fallbackCoords[widget.cityName] ?? const LatLng(14.7167, -17.4677);
    final cityPos  = model != null
        ? LatLng(model.latitude, model.longitude)
        : fallback;

    final displayTemp      = model?.tempDisplay ?? '${widget.temp}°';
    final displayCondition = model?.description ?? widget.condition;

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

    final titleColor    = isLight ? AppTheme.lightText : Colors.white;
    final subtitleColor = isLight ? AppTheme.lightBg2  : AppTheme.accentPurple;
    final mutedColor    = isLight ? AppTheme.lightText.withOpacity(0.5) : Colors.white54;
    final cardBg        = isLight
        ? AppTheme.lightBg2.withOpacity(0.1)
        : Colors.white.withOpacity(0.05);

    final forecast    = model != null ? _buildForecast(model) : <Map<String, dynamic>>[];
    final currentIcon = model != null ? _iconFromCode(model.icon) : null;

    return Scaffold(
      backgroundColor: isLight ? AppTheme.lightBg1 : AppTheme.bgDeep,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [

            // ── Header ────────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: titleColor, size: 22),
                      onPressed: () => context.go('/main'),
                    ),
                    Expanded(
                      child: Text(
                        widget.cityName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (currentIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          currentIcon['icon'] as IconData,
                          color: currentIcon['color'] as Color,
                          size: 28,
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // ── Bannière erreur ───────────────────────────────────────────
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
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(errorMsg,
                          style: TextStyle(color: mutedColor, fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // ── Carte OpenStreetMap ───────────────────────────────────────
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isLight
                      ? AppTheme.lightBg2.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: FlutterMap(
                  options: MapOptions(initialCenter: cityPos, initialZoom: 11.0),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.application_meteo',
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

            // ── Résumé météo actuelle ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: isLoading
                  ? Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (model != null)
                          Image.network(
                            model.iconUrl,
                            width: 36, height: 36,
                            errorBuilder: (_, __, ___) => Icon(
                              currentIcon!['icon'] as IconData,
                              color: currentIcon['color'] as Color,
                              size: 28,
                            ),
                          ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '$displayTemp  •  $displayCondition',
                            style: TextStyle(
                              color: subtitleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (model != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '💧${model.humidity}%  🌬${model.windSpeed.toStringAsFixed(1)}m/s',
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // ── Détails live ──────────────────────────────────────────────
            if (model != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _detailChip(Icons.thermostat_rounded, 'Ressenti',
                          '${model.feelsLike.toStringAsFixed(0)}°',
                          subtitleColor, titleColor, mutedColor),
                      _detailChip(Icons.compress_rounded, 'Pression',
                          '${model.pressure} hPa',
                          subtitleColor, titleColor, mutedColor),
                      _detailChip(Icons.visibility_rounded, 'Visibilité',
                          '${(model.visibility / 1000).toStringAsFixed(0)} km',
                          subtitleColor, titleColor, mutedColor),
                    ],
                  ),
                ),
              ),

            // ── Titre prévisions ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Prévisions 7 jours',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Liste prévisions ──────────────────────────────────────────
            Expanded(
              child: model == null
                  ? Center(
                child: CircularProgressIndicator(
                  color: isLight ? AppTheme.lightBg2 : AppTheme.accentPurple,
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: forecast.length,
                itemBuilder: (context, i) {
                  final item = forecast[i];
                  return _ForecastRow(
                    day:       item['day'],
                    condition: item['condition'],
                    high:      item['high'],
                    low:       item['low'],
                    icon:      item['icon'],
                    iconColor: item['color'],
                    isLight:   isLight,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(
      IconData icon,
      String label,
      String value,
      Color iconColor,
      Color valueColor,
      Color labelColor,
      ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
      ],
    );
  }
}

// ─── Forecast Row ─────────────────────────────────────────────────────────────

class _ForecastRow extends StatelessWidget {
  final String day, condition, high, low;
  final IconData icon;
  final Color iconColor;
  final bool isLight;

  const _ForecastRow({
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
    required this.icon,
    required this.iconColor,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isLight ? AppTheme.lightText : Colors.white;
    final mutedColor = isLight
        ? AppTheme.lightText.withOpacity(0.55)
        : Colors.white54;
    final lowColor = isLight
        ? AppTheme.lightText.withOpacity(0.35)
        : Colors.white38;
    final cardBg = isLight
        ? AppTheme.lightBg2.withOpacity(0.1)
        : Colors.white.withOpacity(0.07);
    final cardBorder = isLight
        ? AppTheme.lightBg2.withOpacity(0.2)
        : Colors.white.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(day,
                style: TextStyle(
                    color: titleColor, fontWeight: FontWeight.w600)),
          ),
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(condition,
                style: TextStyle(color: mutedColor, fontSize: 13)),
          ),
          Text('$high°',
              style: TextStyle(
                  color: titleColor, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('$low°', style: TextStyle(color: lowColor, fontSize: 13)),
        ],
      ),
    );
  }
}