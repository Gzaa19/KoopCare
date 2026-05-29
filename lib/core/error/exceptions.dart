// Low-level exceptions thrown by data sources.
//
// These belong in the data layer. Repositories catch them and translate
// them into `Failure`s before returning to the domain layer.

/// Base class for exceptions originating from data sources.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the server responds with a non-2xx status code.
class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

/// Thrown when the device has no network connectivity or the request times out.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when local cache (SharedPreferences, DB) reads/writes fail.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

/// Thrown when input validation fails before a request is sent.
class ValidationException extends AppException {
  const ValidationException(super.message);
}
