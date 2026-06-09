import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthUser, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(LoginParams params) {
    return repository.login(identifier: params.identifier, pin: params.pin);
  }
}

class LoginParams extends Equatable {
  final String identifier;
  final String pin;

  const LoginParams({required this.identifier, required this.pin});

  @override
  List<Object?> get props => [identifier, pin];
}
