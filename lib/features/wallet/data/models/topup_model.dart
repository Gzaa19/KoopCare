import '../../domain/entities/topup.dart';

/// DTO for the `POST /mobile/topup` response body.
class TopupSessionModel extends TopupSession {
  const TopupSessionModel({
    required super.orderId,
    required super.token,
    required super.redirectUrl,
  });

  factory TopupSessionModel.fromJson(Map<String, dynamic> json) {
    return TopupSessionModel(
      orderId: json['order_id'] as String,
      token: json['token'] as String? ?? '',
      redirectUrl: json['redirect_url'] as String,
    );
  }
}
