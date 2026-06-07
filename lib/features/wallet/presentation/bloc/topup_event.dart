import 'package:equatable/equatable.dart';

abstract class TopupEvent extends Equatable {
  const TopupEvent();
  @override
  List<Object?> get props => [];
}

/// User confirmed an amount and tapped pay → create the Snap session.
class TopupRequested extends TopupEvent {
  final int amount;
  const TopupRequested(this.amount);
  @override
  List<Object?> get props => [amount];
}

/// WebView closed → start polling the backend for settlement.
class TopupPollStatusRequested extends TopupEvent {
  final String orderId;
  const TopupPollStatusRequested(this.orderId);
  @override
  List<Object?> get props => [orderId];
}
