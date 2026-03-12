import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'add_transaction_state.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  final TransactionsRepoImpl transactionsRepo;

  AddTransactionCubit({required this.transactionsRepo})
    : super(AddTransactionInitial());

  void reset() => emit(AddTransactionInitial());

  Future<void> addTransaction({required TransactionModel transaction}) async {
    emit(AddTransactionCreating());

    try {
      if (transaction.type == TransactionType.transfer) {
        final transferId = 'transfer_${DateTime.now().microsecondsSinceEpoch}';

        final expenseDraft = TransactionModel(
          id: '',
          categoryId: null,
          walletId: transaction.walletId,
          goalId: transaction.goalId,
          dayKey: transaction.dayKey,
          periodKey: transaction.periodKey,
          amount: transaction.amount,
          note: transaction.note,
          type: TransactionType.expense,
          transferId: transferId,
        );

        final incomeDraft = TransactionModel(
          id: '',
          categoryId: null,
          walletId: transaction.transferToWalletId,
          goalId: transaction.transferToGoalId,
          dayKey: transaction.dayKey,
          periodKey: transaction.periodKey,
          amount: transaction.amount,
          note: transaction.note,
          type: TransactionType.income,
          transferId: transferId,
        );

        final expense = await transactionsRepo.addTransaction(
          transaction: expenseDraft,
        );
        final income = await transactionsRepo.addTransaction(
          transaction: incomeDraft,
        );

        emit(AddTransactionSuccess(createdTransactions: [expense, income]));
      } else {
        final draft = TransactionModel(
          id: '',
          categoryId: transaction.categoryId,
          walletId: transaction.walletId,
          goalId: transaction.goalId,
          dayKey: transaction.dayKey,
          periodKey: transaction.periodKey,
          amount: transaction.amount,
          note: transaction.note,
          createdAt: transaction.createdAt,
          type: transaction.type,
        );

        final created = await transactionsRepo.addTransaction(
          transaction: draft,
        );

        emit(AddTransactionSuccess(createdTransactions: [created]));
      }
    } catch (e) {
      emit(AddTransactionError(message: e.toString()));
    }
  }
}
