import 'package:equatable/equatable.dart';

import '../../domain/entities/topup.dart';

enum TopupFlowStatus {
  initial,
  creating,
  awaitingPayment,
  polling,
  success,
  processing,
  failure,
}

class TopupState extends Equatable {
  final TopupFlowStatus status;
  final TopupSession? session;
  final String? errorMessage;

  const TopupState({
    this.status = TopupFlowStatus.initial,
    this.session,
    this.errorMessage,
  });

  const TopupState.initial() : this();

  TopupState copyWith({
    TopupFlowStatus? status,
    TopupSession? session,
    String? errorMessage,
  }) {
    return TopupState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage];
}
