import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthUser>> login({
    required String identifier,
    required String pin,
  }) {
    return _guard(() async {
      final result = await remoteDataSource.login(
        identifier: identifier,
        pin: pin,
      );
      await localDataSource.cacheToken(result.token);
      await localDataSource.cacheUser(result.user);
      await localDataSource.cachePin(pin);
      return result.user;
    });
  }

  @override
  Future<Either<Failure, AuthUser>> register({
    required String fullName,
    required String phone,
    required String nik,
    required String pin,
    String? email,
    int monthlyIncome = 0,
  }) {
    return _guard(() async {
      final result = await remoteDataSource.register(
        fullName: fullName,
        phone: phone,
        nik: nik,
        pin: pin,
        email: email,
        monthlyIncome: monthlyIncome,
      );
      await localDataSource.cacheToken(result.token);
      await localDataSource.cacheUser(result.user);
      await localDataSource.cachePin(pin);
      return result.user;
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.readToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthUser?> getCachedUser() => localDataSource.readUser();

  @override
  Future<String?> getCachedPin() => localDataSource.readPin();

  @override
  Future<Either<Failure, AuthUser>> refreshProfile() {
    return _guard(() async {
      final user = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, void>> submitKyc({
    required String ktpFilePath,
    required String selfieFilePath,
  }) {
    return _guard(
      () => remoteDataSource.submitKyc(
        ktpFilePath: ktpFilePath,
        selfieFilePath: selfieFilePath,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> requestOtp(String identifier) {
    return _guard(() => remoteDataSource.requestOtp(identifier));
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String identifier,
    required String otp,
  }) {
    return _guard(
      () => remoteDataSource.verifyOtp(identifier: identifier, otp: otp),
    );
  }

  @override
  Future<Either<Failure, void>> resetPin({
    required String identifier,
    required String otp,
    required String newPin,
  }) {
    return _guard(
      () => remoteDataSource.resetPin(
        identifier: identifier,
        otp: otp,
        newPin: newPin,
      ),
    );
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final value = await action();
      return Right(value);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
