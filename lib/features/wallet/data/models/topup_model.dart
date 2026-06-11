import '../../domain/entities/topup.dart';

class TopupSessionModel extends TopupSession {
  const TopupSessionModel({
    required super.orderId,
    required super.token,
    required super.redirectUrl,
    super.immediatelySettled,
  });

  factory TopupSessionModel.fromJson(Map<String, dynamic> json) {
    return TopupSessionModel(
      orderId: json['order_id'] as String,
      token: json['token'] as String? ?? '',
      redirectUrl: json['redirect_url'] as String,
      immediatelySettled: json['immediately_settled'] as bool? ?? false,
    );
  }
}
