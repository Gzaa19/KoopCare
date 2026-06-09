import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase _getTransactions;

  TransactionBloc({required GetTransactionsUseCase getTransactions})
      : _getTransactions = getTransactions,
        super(const TransactionInitial()) {
    on<FetchTransactions>(_onFetch);
  }

  Future<void> _onFetch(
    FetchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    final result = await _getTransactions();
    emit(
      result.fold(
        (failure) => TransactionError(failure.message),
        (transactions) => TransactionLoaded(transactions),
      ),
    );
  }
}
