/// Application environment configuration.
///
/// Centralizes values that change between dev / staging / production builds
/// so they don't get scattered across feature code.
///
/// For now this is a simple const-based config. When build flavors are added,
/// swap to `String.fromEnvironment` or a flavor-specific [Env] subclass.
class Env {
  Env._();

  /// Base URL for the mobile API.
  ///
  /// - Android emulator → `http://10.0.2.2:3000/api/v1/mobile`
  /// - Physical device  → `http://<lan-ip>:3000/api/v1/mobile`
  /// - Production       → `https://api.koopcare.com/api/v1/mobile`
  static const String apiBaseUrl = 'http://192.168.1.2:3000/api/v1/mobile';

  /// Base URL for the standalone ML credit-scoring service.
  ///
  /// This is a separate FastAPI deployment on Railway, not part of the main
  /// koperasi backend. No auth required.
  static const String mlApiBaseUrl =
      'https://koopcare-mlops-credit-scoring-api-production.up.railway.app';

  /// Default network timeout for HTTP requests.
  static const Duration networkTimeout = Duration(seconds: 15);
}
