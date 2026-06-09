import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ai_scoring_input.dart';
import '../entities/ai_scoring_result.dart';

abstract class AiScoringRepository {
  Future<Either<Failure, AiScoringResult>> predict(AiScoringInput input);
}
