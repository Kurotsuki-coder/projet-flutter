import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/weather_model.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherModel>> getWeatherForCity(String cityName);
  Future<List<Either<Failure, WeatherModel>>> getWeatherForAllCities();
}
