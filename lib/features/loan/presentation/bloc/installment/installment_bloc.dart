import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/installment_model.dart';
import '../../../data/repositories/loan_repository.dart';
import 'installment_event.dart';
import 'installment_state.dart';

class InstallmentBloc extends Bloc<InstallmentEvent, InstallmentState> {
  final LoanRepository repository;

  InstallmentBloc({required this.repository}) : super(InstallmentInitial()) {
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
    try {
      final list = await repository.getInstallments(event.loanId);
      emit(InstallmentLoaded(list));
    } catch (e) {
      emit(InstallmentError(_clean(e)));
    }
  }

  // ── Pay from in-wallet balance ─────────────────────────────────────────────
  Future<void> _onPay(
    PayInstallmentFromBalance event,
    Emitter<InstallmentState> emit,
  ) async {
    final current = _currentInstallments();
    emit(InstallmentPaying(current, event.installmentId));
    try {
      await repository.payInstallmentFromBalance(
        event.loanId,
        event.installmentId,
      );
      // Re-fetch to get the authoritative updated statuses.
      final fresh = await repository.getInstallments(event.loanId);
      emit(InstallmentPaidSuccess(fresh));
    } catch (e) {
      // Re-fetch so the list is still correct, but report the error.
      try {
        final fresh = await repository.getInstallments(event.loanId);
        emit(InstallmentError(_clean(e), fresh));
      } catch (_) {
        emit(InstallmentError(_clean(e)));
      }
    }
  }

  // ── Pay via Midtrans — create Snap session, hand redirect URL to the UI ────
  Future<void> _onPayMidtrans(
    PayInstallmentViaMidtrans event,
    Emitter<InstallmentState> emit,
  ) async {
    final current = _currentInstallments();
    try {
      final session = await repository.payInstallmentViaMidtrans(
        event.loanId,
        event.installmentId,
      );
      emit(
        InstallmentMidtransReady(
          installments: current,
          redirectUrl: session['redirect_url'],
          loanId: event.loanId,
          installmentId: event.installmentId,
        ),
      );
    } catch (e) {
      emit(InstallmentError(_clean(e), current));
    }
  }

  // ── Poll for settlement after the WebView closes ───────────────────────────
  Future<void> _onPollPayment(
    PollInstallmentPayment event,
    Emitter<InstallmentState> emit,
  ) async {
    // Poll up to 5 times, 2s apart — the webhook is asynchronous.
    for (var i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final status = await repository.getInstallmentPaymentStatus(
          event.loanId,
          event.installmentId,
        );
        if (status == 'SETTLED') {
          final fresh = await repository.getInstallments(event.loanId);
          emit(InstallmentPaidSuccess(fresh));
          return;
        }
        if (status == 'FAILED' || status == 'EXPIRED') {
          final fresh = await repository.getInstallments(event.loanId);
          emit(InstallmentError('Pembayaran gagal atau kadaluarsa', fresh));
          return;
        }
      } catch (_) {
        // transient error — keep trying
      }
    }

    // Still pending after polling — the webhook is lagging, NOT a confirmed
    // success. Re-fetch (in case it landed between polls) and report a neutral
    // "processing" state rather than falsely claiming success.
    final fresh = await repository.getInstallments(event.loanId);
    emit(InstallmentProcessing(fresh));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// The installment list from whichever state currently carries one, so a
  /// transient state (paying / error) keeps the list instead of blanking out.
  List<InstallmentModel> _currentInstallments() {
    final s = state;
    if (s is InstallmentLoaded) return s.installments;
    if (s is InstallmentPaidSuccess) return s.installments;
    if (s is InstallmentProcessing) return s.installments;
    if (s is InstallmentMidtransReady) return s.installments;
    return const <InstallmentModel>[];
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}