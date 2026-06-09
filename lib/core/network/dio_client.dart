import 'package:dio/dio.dart';

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    final dio = _baseDio(Env.apiBaseUrl);
    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
    ]);
    return dio;
  }

  static Dio _baseDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Env.networkTimeout,
        receiveTimeout: Env.networkTimeout,
        sendTimeout: Env.networkTimeout,
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );
  }
}
