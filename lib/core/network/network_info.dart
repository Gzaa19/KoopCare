/// Abstraction for connectivity checks used by repositories.
///
/// The default implementation is intentionally permissive (always returns
/// `true`) so the app behaves exactly like before. Swap in a real check
/// (e.g. `connectivity_plus` or `internet_connection_checker`) when the
/// dependency is added — repositories don't need to change.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class AlwaysOnlineNetworkInfo implements NetworkInfo {
  const AlwaysOnlineNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}
