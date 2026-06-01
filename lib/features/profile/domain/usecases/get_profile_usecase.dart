import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Fetches the member's personal profile (general info).
class GetProfileUseCase implements UseCase<Profile, NoParams> {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(NoParams params) {
    return repository.getProfile();
  }
}
