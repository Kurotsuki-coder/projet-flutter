import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';
import '../repositories/weather_repository_impl.dart';
import '../services/weather_api_service.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final dioProvider = Provider((_) => DioClient.create());

final networkInfoProvider = Provider<NetworkInfo>((_) => NetworkInfoImpl());

final weatherApiServiceProvider = Provider<WeatherApiService>(
  (ref) => WeatherApiService(ref.read(dioProvider)),
);

// ── Repository ────────────────────────────────────────────────────────────────

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(
    apiService: ref.read(weatherApiServiceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// ── Data providers (consumed by UI) ──────────────────────────────────────────

/// Fetches all 5 cities concurrently. Used by MainScreen.
final allCitiesWeatherProvider =
    FutureProvider<List<Either<Failure, WeatherModel>>>(
  (ref) => ref.read(weatherRepositoryProvider).getWeatherForAllCities(),
);

/// Single city fetch. Used by CityDetailScreen for live data.
final singleCityWeatherProvider =
FutureProvider.family<Either<Failure, WeatherModel>, String>(
      (ref, cityName) =>
      ref.watch(weatherRepositoryProvider).getWeatherForCity(cityName),
);
