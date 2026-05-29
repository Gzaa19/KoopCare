import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_scoring_input.dart';

abstract class AiScoringEvent extends Equatable {
  const AiScoringEvent();

  @override
  List<Object?> get props => [];
}

/// User finished the multi-step form — run the prediction.
class AiScoringPredictionRequested extends AiScoringEvent {
  final AiScoringInput input;

  const AiScoringPredictionRequested(this.input);

  @override
  List<Object?> get props => [input];
}

/// Reset back to idle (e.g. when leaving the result screen).
class AiScoringReset extends AiScoringEvent {
  const AiScoringReset();
}
