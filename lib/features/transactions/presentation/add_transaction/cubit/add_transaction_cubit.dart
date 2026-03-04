import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'add_transaction_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepoImpl transactionsRepo;

  TransactionsCubit({required this.transactionsRepo})
    : super(TransactionsInitial());

  Future<void> loadTransactions() async {
    try {
      emit(TransactionsLoading());
      final transactions = await transactionsRepo.getUserTransactions();

      if (transactions.isEmpty) {
        emit(TransactionsEmpty());
      } else {
        emit(TransactionsLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionsError(message: e.toString()));
    }
  }

  Future<void> addTransaction({required TransactionModel transaction}) async {
    final previousTransactions = _currentTransactionsOrNull() ?? [];

    emit(TransactionCreating(previousTransactions: previousTransactions));

    try {
      final draft = TransactionModel(
        id: '',
        categoryId: transaction.categoryId,
        amount: transaction.amount,
        note: transaction.note,
        createdAt: transaction.createdAt,
        type: transaction.type,
      );

      final created = await transactionsRepo.addTransaction(transaction: draft);

      final updated = <TransactionModel>[created, ...previousTransactions];

      emit(
        TransactionCreateSuccess(
          transactions: updated,
          createdTransaction: created,
        ),
      );
    } catch (e) {
      emit(
        TransactionCreateError(
          message: e.toString(),
          previousTransactions: previousTransactions,
        ),
      );
    }
  }

  List<TransactionModel>? _currentTransactionsOrNull() {
    final current = state;

    if (current is TransactionsLoaded) {
      return current.transactions;
    }

    if (current is TransactionCreating) {
      return current.previousTransactions;
    }

    if (current is TransactionCreateSuccess) {
      return current.transactions;
    }

    if (current is TransactionCreateError) {
      return current.previousTransactions;
    }

    return null;
  }
}
