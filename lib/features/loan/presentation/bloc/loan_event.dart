import 'package:equatable/equatable.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

class FetchLoans extends LoanEvent {
  const FetchLoans();
}
