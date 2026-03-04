// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Impossible de se connecter au réseau.']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({String message = 'Erreur serveur.', this.statusCode}) : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Clé API invalide ou manquante.']);
}

class CityNotFoundFailure extends Failure {
  final String city;
  const CityNotFoundFailure(this.city) : super('Ville introuvable');

  @override
  List<Object> get props => [message, city];
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Erreur lors du traitement des données.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
