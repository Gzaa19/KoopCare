import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_remote_datasource.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LoanRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Loan>>> getMemberLoans() async {
    try {
      final models = await remoteDataSource.getMemberLoans();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      return Left(ServerFailure(msg, statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Installment>>> getInstallments(
      int loanId) async {
    try {
      final models = await remoteDataSource.getInstallments(loanId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      return Left(ServerFailure(msg, statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> payInstallmentFromBalance(
      int loanId, int installmentId) async {
    try {
      await remoteDataSource.payInstallmentFromBalance(loanId, installmentId);
      return const Right(null);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      return Left(ServerFailure(msg, statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> payInstallmentViaMidtrans(
      int loanId, int installmentId) async {
    try {
      final result = await remoteDataSource.payInstallmentViaMidtrans(
          loanId, installmentId);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      return Left(ServerFailure(msg, statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getInstallmentPaymentStatus(
      int loanId, int installmentId) async {
    try {
      final status = await remoteDataSource.getInstallmentPaymentStatus(
          loanId, installmentId);
      return Right(status);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      return Left(ServerFailure(msg, statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
