import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_loans_usecase.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final GetLoansUseCase getLoans;

  LoanBloc({required this.getLoans}) : super(LoanInitial()) {
    on<FetchLoans>(_onFetchLoans);
  }

  Future<void> _onFetchLoans(
      FetchLoans event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    debugPrint('[LoanBloc] Fetching loans...');
    final result = await getLoans(const NoParams());
    result.fold(
      (failure) {
        debugPrint('[LoanBloc] ERROR: ${failure.message}');
        emit(LoanError(message: failure.message));
      },
      (loans) {
        debugPrint('[LoanBloc] Loaded ${loans.length} loans');
        for (final l in loans) {
          debugPrint(
              '[LoanBloc]   → id=${l.id} status=${l.status} amount=${l.amount} approvedAmount=${l.approvedAmount}');
        }
        emit(LoanLoaded(loans: loans));
      },
    );
  }
}
