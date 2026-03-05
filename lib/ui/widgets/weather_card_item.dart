import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models/weather_model.dart';

class WeatherCardItem extends StatelessWidget {
  final WeatherModel? model;
  final String cityName;
  final String temp;
  final String condition;
  final bool isLight;

  const WeatherCardItem({
    super.key,
    this.model,
    required this.cityName,
    required this.temp,
    required this.condition,
    this.isLight = false,
  });

  factory WeatherCardItem.fromModel(WeatherModel m, {bool isLight = false}) =>
      WeatherCardItem(
        model: m,
        cityName: m.cityName,
        temp: m.tempInt,
        condition: m.description,
        isLight: isLight,
      );

  // ── Mapper code OWM → IconData + couleur ─────────────────────────────────
  static Map<String, dynamic> _iconFromCode(String code) {
    if (code.startsWith('01d')) {
      return {'icon': Icons.wb_sunny_rounded,    'color': const Color(0xFFFFD600)};
    } else if (code.startsWith('01n')) {
      return {'icon': Icons.nightlight_round,    'color': const Color(0xFF90CAF9)};
    } else if (code.startsWith('02d')) {
      return {'icon': Icons.wb_cloudy_rounded,   'color': const Color(0xFFFFCA28)};
    } else if (code.startsWith('02n')) {
      return {'icon': Icons.wb_cloudy_rounded,   'color': const Color(0xFF78909C)};
    } else if (code.startsWith('03')) {
      return {'icon': Icons.cloud_rounded,        'color': const Color(0xFFB0BEC5)};
    } else if (code.startsWith('04')) {
      return {'icon': Icons.cloud_rounded,        'color': const Color(0xFF607D8B)};
    } else if (code.startsWith('09')) {
      return {'icon': Icons.grain_rounded,        'color': const Color(0xFF42A5F5)};
    } else if (code.startsWith('10d')) {
      return {'icon': Icons.umbrella_rounded,     'color': const Color(0xFF1E88E5)};
    } else if (code.startsWith('10n')) {
      return {'icon': Icons.umbrella_rounded,     'color': const Color(0xFF1565C0)};
    } else if (code.startsWith('11')) {
      return {'icon': Icons.thunderstorm_rounded, 'color': const Color(0xFF7C4DFF)};
    } else if (code.startsWith('13')) {
      return {'icon': Icons.ac_unit_rounded,      'color': const Color(0xFF80DEEA)};
    } else if (code.startsWith('50')) {
      return {'icon': Icons.foggy,                'color': const Color(0xFF90A4AE)};
    }
    return   {'icon': Icons.wb_sunny_rounded,     'color': const Color(0xFFFFD600)};
  }

  @override
  Widget build(BuildContext context) {
    final displayTemp      = model != null ? model!.tempInt   : temp;
    final displayCondition = model != null ? model!.description : condition;
    final displayCity      = model != null ? model!.cityName  : cityName;

    // Icône adaptée à la météo réelle
    final iconData = model != null
        ? _iconFromCode(model!.icon)
        : {'icon': Icons.cloud, 'color': const Color(0xFFB0BEC5)};

    final cardBg     = isLight
        ? AppTheme.lightBg2.withOpacity(0.12)
        : Colors.white.withOpacity(0.08);
    final cardBorder = isLight
        ? AppTheme.lightBg2.withOpacity(0.25)
        : Colors.white.withOpacity(0.1);
    final cityColor      = isLight ? AppTheme.lightText : Colors.white;
    final conditionColor = isLight ? AppTheme.lightText.withOpacity(0.6) : Colors.white54;
    final detailColor    = isLight ? AppTheme.lightText.withOpacity(0.4) : Colors.white38;
    final tempColor      = isLight ? AppTheme.lightBg2 : AppTheme.accentPurple;

    return GestureDetector(
      onTap: () {
        context.push('/animations', extra: {
          'cityName':  displayCity,
          'temp':      displayTemp,
          'condition': displayCondition,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Icon(
              iconData['icon'] as IconData,
              color: iconData['color'] as Color,
              size: 36,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayCity,
                    style: TextStyle(
                        color: cityColor, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    displayCondition,
                    style: TextStyle(color: conditionColor, fontSize: 12),
                  ),
                  if (model != null)
                    Text(
                      'Humidité ${model!.humidity}%  •  ${model!.windSpeed.toStringAsFixed(1)} m/s',
                      style: TextStyle(color: detailColor, fontSize: 11),
                    ),
                ],
              ),
            ),
            Text(
              '$displayTemp°',
              style: TextStyle(
                  color: tempColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}