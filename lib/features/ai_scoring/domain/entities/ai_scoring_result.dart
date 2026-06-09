import 'package:equatable/equatable.dart';

enum AiRecommendation { layak, tidakLayak }

enum AiRiskLevel {
  low('Rendah'),
  medium('Sedang'),
  high('Tinggi');

  final String label;
  const AiRiskLevel(this.label);
}

class AiScoringResult extends Equatable {
  final int loanId;

  final AiRecommendation recommendation;

  final double probDefault;

  final AiRiskLevel riskLevel;

  final int aiScore;

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
