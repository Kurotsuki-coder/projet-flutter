// lib/ui/widgets/weather_card_item.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models/weather_model.dart';

class WeatherCardItem extends StatelessWidget {
  /// When [model] is provided, real API data is shown.
  /// When null (loading / error), [cityName], [temp], [condition] fallbacks are used.
  final WeatherModel? model;
  final String cityName;
  final String temp;
  final String condition;

  const WeatherCardItem({
    super.key,
    this.model,
    required this.cityName,
    required this.temp,
    required this.condition,
  });

  /// Convenience constructor from a real WeatherModel.
  factory WeatherCardItem.fromModel(WeatherModel m) => WeatherCardItem(
        model: m,
        cityName: m.cityName,
        temp: m.tempInt,
        condition: m.description,
      );

  @override
  Widget build(BuildContext context) {
    final displayTemp = model != null ? model!.tempInt : temp;
    final displayCondition = model != null ? model!.description : condition;
    final displayCity = model != null ? model!.cityName : cityName;

    return GestureDetector(
      onTap: () {
        context.push('/animations', extra: {
          'cityName': displayCity,
          'temp': displayTemp,
          'condition': displayCondition,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Weather icon from API or fallback
            model != null
                ? Image.network(
                    model!.iconUrl,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.cloud,
                      color: Colors.white70,
                      size: 30,
                    ),
                  )
                : const Icon(Icons.cloud, color: Colors.white70, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayCity,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    displayCondition,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (model != null)
                    Text(
                      'Humidité ${model!.humidity}%  •  ${model!.windSpeed.toStringAsFixed(1)} m/s',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                ],
              ),
            ),
            Text(
              '$displayTemp°',
              style: const TextStyle(
                  color: AppTheme.accentPurple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
