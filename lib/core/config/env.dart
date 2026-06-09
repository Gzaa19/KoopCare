class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://defrayable-disingenuously-annalisa.ngrok-free.dev/api/v1/mobile',
  );

  static const Duration networkTimeout = Duration(seconds: 15);
}
