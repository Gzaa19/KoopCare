import 'package:equatable/equatable.dart';

/// Result of creating a Midtrans Snap transaction on the backend.
/// Mirrors the JSON from `POST /mobile/topup`.
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

/// Settlement status for a top-up, polled from
/// `GET /mobile/topup/:orderId/status`.
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
