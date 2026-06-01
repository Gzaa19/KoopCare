import '../../domain/entities/ai_scoring_result.dart';

/// Data-layer DTO that deserializes the `GET /loans/:id` response body
/// (`data` sub-object) into the domain [AiScoringResult] entity.
class AiScoringResultModel extends AiScoringResult {
  const AiScoringResultModel({
    required super.loanId,
    required super.recommendation,
    required super.probDefault,
    required super.riskLevel,
    required super.aiScore,
    super.maxApprovedAmount,
  });

  /// [loanId] is passed in separately (from the apply response) because the
  /// poll endpoint's `data` object also contains it, but we already have it.
  factory AiScoringResultModel.fromJson(
    int loanId,
    Map<String, dynamic> json,
  ) {
    final rec = _parseRecommendation(json['ai_recommendation'] as String?);
    final prob = double.tryParse(json['prob_default']?.toString() ?? '') ?? 0.5;
    final risk = _parseRiskLevel(json['risk_level'] as String?);
    final score = int.tryParse(json['ai_score']?.toString() ?? '') ??
        (rec == AiRecommendation.layak ? 80 : 20);
    final maxAmount =
        double.tryParse(json['max_approved_amount']?.toString() ?? '');

    return AiScoringResultModel(
      loanId: loanId,
      recommendation: rec,
      probDefault: prob,
      riskLevel: risk,
      aiScore: score,
      maxApprovedAmount: maxAmount,
    );
  }

  static AiRecommendation _parseRecommendation(String? raw) {
    return raw == 'LAYAK' ? AiRecommendation.layak : AiRecommendation.tidakLayak;
  }

  static AiRiskLevel _parseRiskLevel(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'LOW':
        return AiRiskLevel.low;
      case 'MEDIUM':
        return AiRiskLevel.medium;
      case 'HIGH':
      default:
        return AiRiskLevel.high;
    }
  }
}
