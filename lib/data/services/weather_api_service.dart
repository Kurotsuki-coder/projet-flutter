// lib/data/services/weather_api_service.dart

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'weather_api_service.g.dart';

@RestApi()
abstract class WeatherApiService {
  factory WeatherApiService(Dio dio, {String? baseUrl}) = _WeatherApiService;

  /// GET /weather?q={cityName}
  /// API key, units, lang are injected by DioClient interceptor.
  @GET('weather')
  Future<HttpResponse<dynamic>> getCurrentWeather(
    @Query('q') String cityName,
  );
}
