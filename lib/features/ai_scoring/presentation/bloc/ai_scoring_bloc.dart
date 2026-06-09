import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/predict_ai_score_usecase.dart';
import 'ai_scoring_event.dart';
import 'ai_scoring_state.dart';

class AiScoringBloc extends Bloc<AiScoringEvent, AiScoringState> {
  final PredictAiScoreUseCase _predictUseCase;

  AiScoringBloc({required PredictAiScoreUseCase predictUseCase})
      : _predictUseCase = predictUseCase,
        super(const AiScoringState.idle()) {
    on<AiScoringPredictionRequested>(_onPredictionRequested);
    on<AiScoringReset>((_, emit) => emit(const AiScoringState.idle()));
  }

  Future<void> _onPredictionRequested(
    AiScoringPredictionRequested event,
    Emitter<AiScoringState> emit,
  ) async {
    emit(const AiScoringState.loading());
    final result = await _predictUseCase(event.input);
    emit(
      result.fold(
        (failure) => AiScoringState.error(failure.message),
        (success) => AiScoringState.success(success),
      ),
    );
  }
}
