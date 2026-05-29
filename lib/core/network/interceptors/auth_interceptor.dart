import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Attaches `Authorization: Bearer <token>` to every outbound request when a
/// JWT is present in [SharedPreferences] under [tokenKey].
class AuthInterceptor extends Interceptor {
  /// Storage key for the JWT. Must match the key used elsewhere in the app
  /// (`ApiService.saveToken` uses `'jwt_token'`).
  static const String tokenKey = 'jwt_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
