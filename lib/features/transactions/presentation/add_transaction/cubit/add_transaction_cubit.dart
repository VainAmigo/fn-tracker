import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'add_transaction_state.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  final TransactionsRepository transactionsRepo;

  AddTransactionCubit({required this.transactionsRepo})
    : super(AddTransactionInitial());

  void reset() => emit(AddTransactionInitial());

  Future<void> addTransaction({required TransactionModel transaction}) async {
    emit(AddTransactionCreating());

    try {
      if (transaction.type == TransactionType.transfer) {
        final (expense, income) = await _createTransferTransactions(
          transaction,
        );
        emit(AddTransactionSuccess(createdTransactions: [expense, income]));
      } else {
        final created = await transactionsRepo.addTransaction(
          transaction: transaction,
        );
        emit(AddTransactionSuccess(createdTransactions: [created]));
      }
    } catch (e) {
      emit(AddTransactionError(message: e.toString()));
    }
  }

  Future<(TransactionModel, TransactionModel)> _createTransferTransactions(
    TransactionModel t,
  ) async {
    final transferId = 'transfer_${DateTime.now().microsecondsSinceEpoch}';

    final expense = await transactionsRepo.addTransaction(
      transaction: TransactionModel(
        id: '',
        categoryId: null,
        walletId: t.walletId,
        goalId: t.goalId,
        dayKey: t.dayKey,
        periodKey: t.periodKey,
        amount: t.amount,
        note: t.note,
        type: TransactionType.expense,
        transferId: transferId,
        date: t.date,
        createdAt: t.createdAt,
      ),
    );

    final income = await transactionsRepo.addTransaction(
      transaction: TransactionModel(
        id: '',
        categoryId: null,
        walletId: t.transferToWalletId,
        goalId: t.transferToGoalId,
        dayKey: t.dayKey,
        periodKey: t.periodKey,
        amount: t.amount,
        note: t.note,
        type: TransactionType.income,
        transferId: transferId,
        date: t.date,
        createdAt: t.createdAt,
      ),
    );

    return (expense, income);
  }
}
