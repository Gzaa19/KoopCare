import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_scoring_result.dart';

enum AiScoringStatus { idle, loading, success, error }

class AiScoringState extends Equatable {
  final AiScoringStatus status;
  final AiScoringResult? result;
  final String? errorMessage;

  const AiScoringState({
    this.status = AiScoringStatus.idle,
    this.result,
    this.errorMessage,
  });

  const AiScoringState.idle() : this();

  const AiScoringState.loading() : this(status: AiScoringStatus.loading);

  const AiScoringState.success(AiScoringResult result)
      : this(status: AiScoringStatus.success, result: result);

  const AiScoringState.error(String message)
      : this(status: AiScoringStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, result, errorMessage];
}
