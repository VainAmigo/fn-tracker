import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

part 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepoImpl transactionsRepo;

  TransactionsCubit({required this.transactionsRepo})
    : super(TransactionsInitial());

  Future<void> loadTransactionsByPeriod(TransactionPeriod period) async {
    try {
      emit(TransactionsLoading());
      final transactions = await transactionsRepo.getUserTransactionsByPeriod(
        start: period.dateRange.start.dayKey,
        end: period.dateRange.end.dayKey,
      );

      if (transactions.isEmpty) {
        emit(TransactionsEmpty());
      } else {
        emit(TransactionsLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionsError(message: e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    final current = state;
    if (current is TransactionsLoaded) {
      final updated =
          current.transactions.where((tx) => tx.id != id).toList();
      if (updated.isEmpty) {
        emit(TransactionsEmpty());
      } else {
        emit(TransactionsLoaded(transactions: updated));
      }
    }
    try {
      await transactionsRepo.deleteTransaction(id: id);
    } catch (_) {}
  }

  void addTransactionLocally(TransactionModel transaction) {
    final current = state;
    final existing = current is TransactionsLoaded
        ? current.transactions
        : <TransactionModel>[];
    emit(TransactionsLoaded(transactions: [transaction, ...existing]));
  }
}
