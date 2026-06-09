import 'package:equatable/equatable.dart';

abstract class InstallmentEvent extends Equatable {
  const InstallmentEvent();
  @override
  List<Object?> get props => [];
}

class FetchInstallments extends InstallmentEvent {
  final int loanId;
  const FetchInstallments(this.loanId);
  @override
  List<Object?> get props => [loanId];
}

class PayInstallmentFromBalance extends InstallmentEvent {
  final int loanId;
  final int installmentId;
  const PayInstallmentFromBalance(this.loanId, this.installmentId);
  @override
  List<Object?> get props => [loanId, installmentId];
}

class PayInstallmentViaMidtrans extends InstallmentEvent {
  final int loanId;
  final int installmentId;
  const PayInstallmentViaMidtrans(this.loanId, this.installmentId);
  @override
  List<Object?> get props => [loanId, installmentId];
}

class PollInstallmentPayment extends InstallmentEvent {
  final int loanId;
  final int installmentId;
  const PollInstallmentPayment(this.loanId, this.installmentId);
  @override
  List<Object?> get props => [loanId, installmentId];
}