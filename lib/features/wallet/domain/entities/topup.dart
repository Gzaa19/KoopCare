import 'package:equatable/equatable.dart';

class TopupSession extends Equatable {
  final String orderId;
  final String token;
  final String redirectUrl;

  const TopupSession({
    required this.orderId,
    required this.token,
    required this.redirectUrl,
  });

  @override
  List<Object?> get props => [orderId, token, redirectUrl];
}

enum TopupStatus { pending, settled, failed, expired, unknown }

TopupStatus topupStatusFromString(String? s) {
  switch (s) {
    case 'SETTLED':
      return TopupStatus.settled;
    case 'FAILED':
      return TopupStatus.failed;
    case 'EXPIRED':
      return TopupStatus.expired;
    case 'PENDING':
      return TopupStatus.pending;
    default:
      return TopupStatus.unknown;
  }
}
