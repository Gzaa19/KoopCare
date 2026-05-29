import 'package:dio/dio.dart';

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Builds the application-wide [Dio] instances.
///
/// Construction is centralized here so every feature uses the same base URL,
/// timeouts, and interceptor stack.
class DioClient {
  DioClient._();

  /// Default client for the koperasi backend (auth-protected).
  static Dio create() {
    final dio = _baseDio(Env.apiBaseUrl);
    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
    ]);
    return dio;
  }

  /// Standalone client for the ML credit-scoring service. No auth.
  static Dio createMl() {
    final dio = _baseDio(Env.mlApiBaseUrl);
    dio.interceptors.add(ErrorInterceptor());
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
