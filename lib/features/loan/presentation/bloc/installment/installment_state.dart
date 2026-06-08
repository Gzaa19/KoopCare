import 'package:equatable/equatable.dart';
import '../../../data/models/installment_model.dart';

abstract class InstallmentState extends Equatable {
  const InstallmentState();
  @override
  List<Object?> get props => [];
}

class InstallmentInitial extends InstallmentState {}

class InstallmentLoading extends InstallmentState {}

class InstallmentLoaded extends InstallmentState {
  final List<InstallmentModel> installments;
  const InstallmentLoaded(this.installments);
  @override
  List<Object?> get props => [installments];
}

/// A balance payment is in flight for [payingId].
class InstallmentPaying extends InstallmentState {
  final List<InstallmentModel> installments;
  final int payingId;
  const InstallmentPaying(this.installments, this.payingId);
  @override
  List<Object?> get props => [installments, payingId];
}

/// A Snap session is ready; the page should open the Midtrans WebView.
class InstallmentMidtransReady extends InstallmentState {
  final List<InstallmentModel> installments;
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

/// Payment confirmed (balance path, or Midtrans webhook settled).
class InstallmentPaidSuccess extends InstallmentState {
  final List<InstallmentModel> installments;
  const InstallmentPaidSuccess(this.installments);
  @override
  List<Object?> get props => [installments];
}

/// Midtrans payment not yet confirmed after polling — webhook lag, NOT a
/// failure and NOT a confirmed success. Show a neutral "processing" message.
class InstallmentProcessing extends InstallmentState {
  final List<InstallmentModel> installments;
  const InstallmentProcessing(this.installments);
  @override
  List<Object?> get props => [installments];
}

class InstallmentError extends InstallmentState {
  final String message;
  // Keep the last-known list so the UI doesn't blank out on a failed payment.
  final List<InstallmentModel> installments;
  const InstallmentError(this.message, [this.installments = const []]);
  @override
  List<Object?> get props => [message, installments];
}