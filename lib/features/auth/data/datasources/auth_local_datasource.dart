import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

/// Persists auth state on the device.
///
/// Uses the same `'jwt_token'` key as the legacy `ApiService` so existing
/// pages that read the token continue to work during the migration.
abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> readToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _kTokenKey = 'jwt_token';

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
  }
}
