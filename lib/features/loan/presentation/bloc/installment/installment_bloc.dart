import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/installment.dart';
import '../../../domain/usecases/get_installments_usecase.dart';
import '../../../domain/usecases/get_payment_status_usecase.dart';
import '../../../domain/usecases/pay_installment_midtrans_usecase.dart';
import '../../../domain/usecases/pay_installment_usecase.dart';
import 'installment_event.dart';
import 'installment_state.dart';

class InstallmentBloc extends Bloc<InstallmentEvent, InstallmentState> {
  final GetInstallmentsUseCase getInstallments;
  final PayInstallmentUseCase payInstallment;
  final PayInstallmentMidtransUseCase payMidtrans;
  final GetPaymentStatusUseCase getPaymentStatus;

  InstallmentBloc({
    required this.getInstallments,
    required this.payInstallment,
    required this.payMidtrans,
    required this.getPaymentStatus,
  }) : super(InstallmentInitial()) {
    on<FetchInstallments>(_onFetch);
    on<PayInstallmentFromBalance>(_onPay);
    on<PayInstallmentViaMidtrans>(_onPayMidtrans);
    on<PollInstallmentPayment>(_onPollPayment);
  }

  Future<void> _onFetch(
    FetchInstallments event,
    Emitter<InstallmentState> emit,
  ) async {
    emit(InstallmentLoading());
    final result = await getInstallments(event.loanId);
    result.fold(
      (failure) => emit(InstallmentError(failure.message)),
      (list) => emit(InstallmentLoaded(list)),
    );
  }

  Future<void> _onPay(
    PayInstallmentFromBalance event,
    Emitter<InstallmentState> emit,
  ) async {
    final current = _currentInstallments();
    emit(InstallmentPaying(current, event.installmentId));

    final result = await payInstallment(PayInstallmentParams(
      loanId: event.loanId,
      installmentId: event.installmentId,
    ));

    await result.fold(
      (failure) async {
        final refetch = await getInstallments(event.loanId);
        refetch.fold(
          (_) => emit(InstallmentError(failure.message)),
          (fresh) => emit(InstallmentError(failure.message, fresh)),
        );
      },
      (_) async {
        final refetch = await getInstallments(event.loanId);
        refetch.fold(
          (_) => emit(InstallmentPaidSuccess(current)),
          (fresh) => emit(InstallmentPaidSuccess(fresh)),
        );
      },
    );
  }

  Future<void> _onPayMidtrans(
    PayInstallmentViaMidtrans event,
    Emitter<InstallmentState> emit,
  ) async {
    final current = _currentInstallments();

    final result = await payMidtrans(PayMidtransParams(
      loanId: event.loanId,
      installmentId: event.installmentId,
    ));

    result.fold(
      (failure) => emit(InstallmentError(failure.message, current)),
      (session) => emit(
        InstallmentMidtransReady(
          installments: current,
          redirectUrl: session['redirect_url'],
          loanId: event.loanId,
          installmentId: event.installmentId,
        ),
      ),
    );
  }

  Future<void> _onPollPayment(
    PollInstallmentPayment event,
    Emitter<InstallmentState> emit,
  ) async {
    for (var i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final result = await getPaymentStatus(PaymentStatusParams(
        loanId: event.loanId,
        installmentId: event.installmentId,
      ));

      final shouldReturn = await result.fold(
        (_) async => false,
        (status) async {
          if (status == 'SETTLED') {
            final refetch = await getInstallments(event.loanId);
            refetch.fold(
              (_) => emit(InstallmentPaidSuccess(_currentInstallments())),
              (fresh) => emit(InstallmentPaidSuccess(fresh)),
            );
            return true;
          }
          if (status == 'FAILED' || status == 'EXPIRED') {
            final refetch = await getInstallments(event.loanId);
            refetch.fold(
              (_) => emit(InstallmentError(
                  'Pembayaran gagal atau kadaluarsa', _currentInstallments())),
              (fresh) => emit(
                  InstallmentError('Pembayaran gagal atau kadaluarsa', fresh)),
            );
            return true;
          }
          return false;
        },
      );

      if (shouldReturn) return;
    }

    final refetch = await getInstallments(event.loanId);
    refetch.fold(
      (_) => emit(InstallmentProcessing(_currentInstallments())),
      (fresh) => emit(InstallmentProcessing(fresh)),
    );
  }

  List<Installment> _currentInstallments() {
    final s = state;
    if (s is InstallmentLoaded) return s.installments;
    if (s is InstallmentPaidSuccess) return s.installments;
    if (s is InstallmentProcessing) return s.installments;
    if (s is InstallmentMidtransReady) return s.installments;
    return const <Installment>[];
  }
}