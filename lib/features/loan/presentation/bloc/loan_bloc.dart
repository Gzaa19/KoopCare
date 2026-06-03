import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/loan_repository.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository repository;

  LoanBloc({required this.repository}) : super(LoanInitial()) {
    on<FetchLoans>(_onFetchLoans);
  }

  Future<void> _onFetchLoans(
      FetchLoans event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      debugPrint('[LoanBloc] Fetching loans...');
      final loans = await repository.getMemberLoans();
      debugPrint('[LoanBloc] Loaded ${loans.length} loans');
      for (final l in loans) {
        debugPrint('[LoanBloc]   → id=${l.id} status=${l.status} amount=${l.amount} approvedAmount=${l.approvedAmount}');
      }
      emit(LoanLoaded(loans: loans));
    } catch (e) {
      debugPrint('[LoanBloc] ERROR: $e');
      emit(LoanError(message: e.toString()));
    }
  }
}
