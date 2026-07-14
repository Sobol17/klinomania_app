import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({Dio? dio, String baseUrl = ''})
    : _dio = dio ?? Dio(_defaultOptions(baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _notifyUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  String? _token;
  Future<void> Function()? _onUnauthorized;
  bool _isHandlingUnauthorized = false;

  static BaseOptions _defaultOptions(String baseUrl) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    );
  }

  Dio get client => _dio;

  /// Registers the application-level action for an expired or invalid session.
  void setUnauthorizedHandler(Future<void> Function()? handler) {
    _onUnauthorized = handler;
  }

  void setAuthToken(String? token, {String tokenType = 'Bearer'}) {
    _token = token;
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }

    _dio.options.headers['Authorization'] = '$tokenType $token';
  }

  String? get token => _token;

  Future<void> _notifyUnauthorized() async {
    final handler = _onUnauthorized;
    if (handler == null || _isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      await handler();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
