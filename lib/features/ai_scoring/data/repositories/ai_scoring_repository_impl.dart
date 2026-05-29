import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ai_scoring_input.dart';
import '../../domain/entities/ai_scoring_result.dart';
import '../../domain/repositories/ai_scoring_repository.dart';
import '../datasources/ai_scoring_remote_datasource.dart';

class AiScoringRepositoryImpl implements AiScoringRepository {
  final AiScoringRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const AiScoringRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AiScoringResult>> predict(AiScoringInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.predict(input);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
