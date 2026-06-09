import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_scoring_input.dart';

abstract class AiScoringEvent extends Equatable {
  const AiScoringEvent();

  @override
  List<Object?> get props => [];
}

class AiScoringPredictionRequested extends AiScoringEvent {
  final AiScoringInput input;

  const AiScoringPredictionRequested(this.input);

  @override
  List<Object?> get props => [input];
}

class AiScoringReset extends AiScoringEvent {
  const AiScoringReset();
}
