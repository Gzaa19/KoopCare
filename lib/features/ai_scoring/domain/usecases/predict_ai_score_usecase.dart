import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_scoring_input.dart';
import '../entities/ai_scoring_result.dart';
import '../repositories/ai_scoring_repository.dart';

/// Runs the credit-scoring model against the user's profile.
class PredictAiScoreUseCase implements UseCase<AiScoringResult, AiScoringInput> {
  final AiScoringRepository repository;

  const PredictAiScoreUseCase(this.repository);

  @override
  Future<Either<Failure, AiScoringResult>> call(AiScoringInput params) {
    return repository.predict(params);
  }
}
