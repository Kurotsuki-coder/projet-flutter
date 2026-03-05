import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import 'weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;
  final NetworkInfo _networkInfo;

  const WeatherRepositoryImpl({
    required WeatherApiService apiService,
    required NetworkInfo networkInfo,
  })  : _apiService = apiService,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, WeatherModel>> getWeatherForCity(String cityName) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return const Left(NetworkFailure());

    try {
      final response = await _apiService.getCurrentWeather(cityName);
      final model = WeatherModel.fromJson(response.data as Map<String, dynamic>);
      return Right(model);
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e, cityName));
    } on ParseException catch (e) {
      return Left(ParseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Fetch all 5 cities simultaneously — never sequentially.
  @override
  Future<List<Either<Failure, WeatherModel>>> getWeatherForAllCities() async {
    final futures = AppConstants.targetCities
        .map((city) => getWeatherForCity(city))
        .toList();
    return Future.wait(futures);
  }

  Failure _mapDioToFailure(DioException e, String cityName) {
    if (e.error is NetworkException) return const NetworkFailure();
    if (e.error is ServerException) {
      final se = e.error as ServerException;
      if (se.statusCode == 401) return const AuthFailure();
      if (se.statusCode == 404) return CityNotFoundFailure(cityName);
      return ServerFailure(message: se.message, statusCode: se.statusCode);
    }
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return const AuthFailure();
        if (code == 404) return CityNotFoundFailure(cityName);
        return ServerFailure(message: 'Erreur HTTP $code', statusCode: code);
      default:
        return const UnknownFailure();
    }
  }
}
