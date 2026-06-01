import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile.dart';

/// Contract the profile feature exposes to the rest of the app.
///
/// Implementations live in `data/repositories/`. Use cases depend only on
/// this interface, never on a concrete implementation.
abstract class ProfileRepository {
  /// Fetches the member's full personal profile from `GET /profile`.
  Future<Either<Failure, Profile>> getProfile();
}
