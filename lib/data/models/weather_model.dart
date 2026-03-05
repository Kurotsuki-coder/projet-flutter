import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final int visibility;
  final int cloudiness;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime fetchedAt;

  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.visibility,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.fetchedAt,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
  String get tempDisplay => '${temperature.toStringAsFixed(0)}°';
  String get tempInt => temperature.toStringAsFixed(0);

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    final coord = json['coord'] as Map<String, dynamic>;
    final weather = (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: json['name'] as String,
      country: sys['country'] as String? ?? '',
      latitude: (coord['lat'] as num).toDouble(),
      longitude: (coord['lon'] as num).toDouble(),
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      pressure: main['pressure'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      windDeg: (wind['deg'] as num? ?? 0).toInt(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      visibility: (json['visibility'] as num? ?? 10000).toInt(),
      cloudiness: (clouds['all'] as num? ?? 0).toInt(),
      sunrise: DateTime.fromMillisecondsSinceEpoch((sys['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((sys['sunset'] as int) * 1000),
      fetchedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [cityName, country, temperature, fetchedAt];
}
