class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://koopcare-admin-production.up.railway.app/api/v1/mobile',
  );

  static const Duration networkTimeout = Duration(seconds: 15);
}
