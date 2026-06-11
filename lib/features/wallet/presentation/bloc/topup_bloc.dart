import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/topup.dart';
import '../../domain/usecases/create_topup_usecase.dart';
import '../../domain/usecases/get_topup_status_usecase.dart';
import 'topup_event.dart';
import 'topup_state.dart';

class TopupBloc extends Bloc<TopupEvent, TopupState> {
  final CreateTopupUseCase _createTopup;
  final GetTopupStatusUseCase _getStatus;

  TopupBloc({
    required CreateTopupUseCase createTopup,
    required GetTopupStatusUseCase getStatus,
  }) : _createTopup = createTopup,
       _getStatus = getStatus,
       super(const TopupState.initial()) {
    on<TopupRequested>(_onRequested);
    on<TopupPollStatusRequested>(_onPollStatus);
  }

  Future<void> _onRequested(
    TopupRequested event,
    Emitter<TopupState> emit,
  ) async {
    emit(state.copyWith(status: TopupFlowStatus.creating));
    final result = await _createTopup(event.amount);
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: TopupFlowStatus.failure,
          errorMessage: failure.message,
        ),
        (session) {
          // Backend already settled the transaction (demo mode)
          if (session.immediatelySettled) {
            return state.copyWith(
              status: TopupFlowStatus.success,
              session: session,
            );
          }
          return state.copyWith(
            status: TopupFlowStatus.awaitingPayment,
            session: session,
          );
        },
      ),
    );
  }

  Future<void> _onPollStatus(
    TopupPollStatusRequested event,
    Emitter<TopupState> emit,
  ) async {
    emit(state.copyWith(status: TopupFlowStatus.polling));

    for (var i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final result = await _getStatus(event.orderId);

      final done = result.fold(
        (_) => false,
        (status) {
          if (status == TopupStatus.settled) {
            emit(state.copyWith(status: TopupFlowStatus.success));
            return true;
          }
          if (status == TopupStatus.failed || status == TopupStatus.expired) {
            emit(
              state.copyWith(
                status: TopupFlowStatus.failure,
                errorMessage: 'Pembayaran gagal atau kadaluarsa',
              ),
            );
            return true;
          }
          return false;
        },
      );

      if (done) return;
    }

    emit(state.copyWith(status: TopupFlowStatus.processing));
  }
}
