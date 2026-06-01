import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_user_model.dart';

/// Persists auth state on the device.
///
/// Stores both the JWT token and the cached user object so the home page
/// can display the real name and balance without an extra network call.
abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> readToken();
  Future<void> clearToken();

  Future<void> cacheUser(AuthUserModel user);
  Future<AuthUserModel?> readUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _kTokenKey = 'jwt_token';
  static const String _kUserKey = 'cached_user';

  final SharedPreferences _prefs;

  const AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheToken(String token) async {
    final ok = await _prefs.setString(_kTokenKey, token);
    if (!ok) throw const CacheException('Gagal menyimpan token');
  }

  @override
  Future<String?> readToken() async => _prefs.getString(_kTokenKey);

  @override
  Future<void> clearToken() async {
    await _prefs.remove(_kTokenKey);
    await _prefs.remove(_kUserKey);
  }

  @override
  Future<void> cacheUser(AuthUserModel user) async {
    final json = jsonEncode(user.toJson());
    await _prefs.setString(_kUserKey, json);
  }

  @override
  Future<AuthUserModel?> readUser() async {
    final raw = _prefs.getString(_kUserKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
