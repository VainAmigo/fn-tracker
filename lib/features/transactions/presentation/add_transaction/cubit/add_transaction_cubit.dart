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
      final draft = TransactionModel(
        id: '',
        categoryId: transaction.categoryId,
        walletId: transaction.walletId,
        dayKey: transaction.dayKey,
        periodKey: transaction.periodKey,
        amount: transaction.amount,
        note: transaction.note,
        createdAt: transaction.createdAt,
        type: transaction.type,
      );

      final created = await transactionsRepo.addTransaction(transaction: draft);

      emit(AddTransactionSuccess(createdTransaction: created));
    } catch (e) {
      emit(AddTransactionError(message: e.toString()));
    }
  }
}
