// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion réseau.']);

  @override
  String toString() => 'NetworkException: $message';
}

class CityNotFoundException implements Exception {
  final String city;
  const CityNotFoundException(this.city);

  @override
  String toString() => 'CityNotFoundException: $city introuvable.';
}

class ParseException implements Exception {
  final String message;
  const ParseException([this.message = 'Erreur de parsing JSON.']);

  @override
  String toString() => 'ParseException: $message';
}
