import '../../domain/entities/ai_scoring_result.dart';

/// Data-layer DTO that knows how to deserialize the ML API response and
/// project it onto the domain [AiScoringResult] entity.
class AiScoringResultModel extends AiScoringResult {
  const AiScoringResultModel({
    required super.recommendation,
    required super.probDefault,
    required super.riskLevel,
    required super.aiScore,
  });

  factory AiScoringResultModel.fromJson(Map<String, dynamic> json) {
    final rec = _parseRecommendation(json['recommendation'] as String?);
    final prob = (json['prob_default'] as num?)?.toDouble() ?? 0.5;
    final risk = _parseRiskLevel(json['risk_level'] as String?);
    // Mirror backend convention: LAYAK → 80, TIDAK_LAYAK → 20.
    final score = rec == AiRecommendation.layak ? 80 : 20;
    return AiScoringResultModel(
      recommendation: rec,
      probDefault: prob,
      riskLevel: risk,
      aiScore: score,
    );
  }

  static AiRecommendation _parseRecommendation(String? raw) {
    return raw == 'LAYAK' ? AiRecommendation.layak : AiRecommendation.tidakLayak;
  }

  static AiRiskLevel _parseRiskLevel(String? raw) {
    switch (raw) {
      case 'low':
        return AiRiskLevel.low;
      case 'medium':
        return AiRiskLevel.medium;
      case 'high':
      default:
        return AiRiskLevel.high;
    }
  }
}
