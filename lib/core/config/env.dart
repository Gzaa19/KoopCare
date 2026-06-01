/// Application environment configuration.
///
/// Centralizes values that change between dev / staging / production builds
/// so they don't get scattered across feature code.
///
/// For now this is a simple const-based config. When build flavors are added,
/// swap to `String.fromEnvironment` or a flavor-specific [Env] subclass.
class Env {
  Env._();

  /// Base URL for the mobile API (production — Railway deployment).
  static const String apiBaseUrl =
      'https://koopcare-admin-production.up.railway.app/api/v1/mobile';

  /// Default network timeout for HTTP requests.
  static const Duration networkTimeout = Duration(seconds: 15);
}
