import 'package:equatable/equatable.dart';

enum AiRecommendation { layak, tidakLayak }

enum AiRiskLevel {
  low('Rendah'),
  medium('Sedang'),
  high('Tinggi');

  final String label;
  const AiRiskLevel(this.label);
}

/// Outcome of a credit-scoring prediction, parsed from `GET /loans/:id`.
class AiScoringResult extends Equatable {
  /// The loan ID returned by `POST /loans/apply`, used for polling.
  final int loanId;

  /// Raw recommendation from the model.
  final AiRecommendation recommendation;

  /// Probability of default, in `[0, 1]`.
  final double probDefault;

  /// Risk bucket from the model.
  final AiRiskLevel riskLevel;

  /// 0–100 score from the backend.
  final int aiScore;

  /// Maximum loan amount suggested by the AI (may be null if not yet scored).
  final double? maxApprovedAmount;

  const AiScoringResult({
    required this.loanId,
    required this.recommendation,
    required this.probDefault,
    required this.riskLevel,
    required this.aiScore,
    this.maxApprovedAmount,
  });

  bool get isApproved => recommendation == AiRecommendation.layak;

  @override
  List<Object?> get props => [
        loanId,
        recommendation,
        probDefault,
        riskLevel,
        aiScore,
        maxApprovedAmount,
      ];
}
