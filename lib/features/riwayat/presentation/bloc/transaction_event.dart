import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the member's transaction history.
class FetchTransactions extends TransactionEvent {
  const FetchTransactions();
}
