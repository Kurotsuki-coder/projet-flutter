// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(_ApiKeyInterceptor());
    dio.interceptors.add(
      LogInterceptor(responseBody: true, error: true, logPrint: (o) => print('[Dio] $o')),
    );

    return dio;
  }
}

class _ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      'appid': AppConstants.apiKey,
      'units': AppConstants.units,
      'lang': AppConstants.lang,
    });
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      message: exception.toString(),
      type: err.type,
      response: err.response,
    ));
  }

  Exception _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Délai dépassé ou pas de connexion.');
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return const ServerException(message: 'Clé API invalide.', statusCode: 401);
        if (code == 404) return const ServerException(message: 'Ville introuvable.', statusCode: 404);
        return ServerException(message: 'Erreur serveur ($code).', statusCode: code);
      default:
        return const NetworkException();
    }
  }
}
