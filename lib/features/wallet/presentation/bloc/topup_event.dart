import 'package:equatable/equatable.dart';

abstract class TopupEvent extends Equatable {
  const TopupEvent();
  @override
  List<Object?> get props => [];
}

class TopupRequested extends TopupEvent {
  final int amount;
  const TopupRequested(this.amount);
  @override
  List<Object?> get props => [amount];
}

class TopupPollStatusRequested extends TopupEvent {
  final String orderId;
  const TopupPollStatusRequested(this.orderId);
  @override
  List<Object?> get props => [orderId];
}
