import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login({
    required String identifier,
    required String pin,
  });

  Future<Either<Failure, AuthUser>> register({
    required String fullName,
    required String phone,
    required String nik,
    required String pin,
    String? email,
    int monthlyIncome = 0,
  });

  Future<Either<Failure, void>> logout();

  Future<bool> isLoggedIn();

  Future<Either<Failure, void>> requestOtp(String identifier);

  Future<Either<Failure, void>> verifyOtp({
    required String identifier,
    required String otp,
  });

  Future<Either<Failure, void>> resetPin({
    required String identifier,
    required String otp,
    required String newPin,
  });

  Future<AuthUser?> getCachedUser();

  Future<String?> getCachedPin();

  Future<Either<Failure, AuthUser>> refreshProfile();

  Future<Either<Failure, void>> submitKyc({
    required String ktpFilePath,
    required String selfieFilePath,
  });
}
