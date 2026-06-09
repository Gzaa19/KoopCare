import 'package:equatable/equatable.dart';
import '../../../domain/entities/installment.dart';

abstract class InstallmentState extends Equatable {
  const InstallmentState();
  @override
  List<Object?> get props => [];
}

class InstallmentInitial extends InstallmentState {}

class InstallmentLoading extends InstallmentState {}

class InstallmentLoaded extends InstallmentState {
  final List<Installment> installments;
  const InstallmentLoaded(this.installments);
  @override
  List<Object?> get props => [installments];
}

class InstallmentPaying extends InstallmentState {
  final List<Installment> installments;
  final int payingId;
  const InstallmentPaying(this.installments, this.payingId);
  @override
  List<Object?> get props => [installments, payingId];
}

class InstallmentMidtransReady extends InstallmentState {
  final List<Installment> installments;
  final String redirectUrl;
  final int loanId;
  final int installmentId;
  const InstallmentMidtransReady({
    required this.installments,
    required this.redirectUrl,
    required this.loanId,
    required this.installmentId,
  });
  @override
  List<Object?> get props => [installments, redirectUrl, loanId, installmentId];
}

class InstallmentPaidSuccess extends InstallmentState {
  final List<Installment> installments;
  const InstallmentPaidSuccess(this.installments);
  @override
  List<Object?> get props => [installments];
}

class InstallmentProcessing extends InstallmentState {
  final List<Installment> installments;
  const InstallmentProcessing(this.installments);
  @override
  List<Object?> get props => [installments];
}

class InstallmentError extends InstallmentState {
  final String message;
  final List<Installment> installments;
  const InstallmentError(this.message, [this.installments = const []]);
  @override
  List<Object?> get props => [message, installments];
}