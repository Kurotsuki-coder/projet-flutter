// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build --delete-conflicting-outputs

// ignore_for_file: type=lint, unnecessary_brace_in_string_interps, no_leading_underscores_for_local_identifiers

part of 'weather_api_service.dart';

class _WeatherApiService implements WeatherApiService {
  _WeatherApiService(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  @override
  Future<HttpResponse<dynamic>> getCurrentWeather(String cityName) async {
    final queryParameters = <String, dynamic>{r'q': cityName};
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<HttpResponse<dynamic>>(
        Options(method: 'GET').compose(
          _dio.options,
          'weather',
          queryParameters: queryParameters,
        ).copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final httpResponse = HttpResponse(_result.data!, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) return dioBaseUrl;
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
