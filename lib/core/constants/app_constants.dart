// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // 🔑 Replace with your real OpenWeatherMap API key
  static const String apiKey = '8003939741550b06e95d6b191954d353';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/';
  static const String units = 'metric'; // Celsius
  static const String lang = 'fr';

  // The 5 target cities
  static const List<String> targetCities = [
    'Dakar',
    'Paris',
    'Tokyo',
    'London',
    'Hong Kong',
  ];

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
