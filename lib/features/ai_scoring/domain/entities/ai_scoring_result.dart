import 'package:equatable/equatable.dart';

enum AiRecommendation { layak, tidakLayak }

enum AiRiskLevel {
  low('Rendah'),
  medium('Sedang'),
  high('Tinggi');

  final String label;
  const AiRiskLevel(this.label);
}

/// Outcome of a credit-scoring prediction.
class AiScoringResult extends Equatable {
  /// Raw recommendation from the model.
  final AiRecommendation recommendation;

  /// Probability of default, in `[0, 1]`.
  final double probDefault;

  /// Risk bucket from the model.
  final AiRiskLevel riskLevel;

  /// Derived 0–100 score (mirrors backend convention: 80 if approved, 20 otherwise).
  final int aiScore;

  const AiScoringResult({
    required this.recommendation,
    required this.probDefault,
    required this.riskLevel,
    required this.aiScore,
  });

  bool get isApproved => recommendation == AiRecommendation.layak;

  @override
  List<Object?> get props => [recommendation, probDefault, riskLevel, aiScore];
}
