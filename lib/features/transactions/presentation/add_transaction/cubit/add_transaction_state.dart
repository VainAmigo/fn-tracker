part of 'add_transaction_cubit.dart';

sealed class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsEmpty extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;

  TransactionsLoaded({required this.transactions});
}

class TransactionsError extends TransactionsState {
  final String message;

  TransactionsError({required this.message});
}

class TransactionCreating extends TransactionsState {
  final List<TransactionModel> previousTransactions;

  TransactionCreating({required this.previousTransactions});
}

class TransactionCreateSuccess extends TransactionsState {
  final List<TransactionModel> transactions;
  final TransactionModel createdTransaction;

  TransactionCreateSuccess({
    required this.transactions,
    required this.createdTransaction,
  });
}

class TransactionCreateError extends TransactionsState {
  final String message;
  final List<TransactionModel>? previousTransactions;

  TransactionCreateError({
    required this.message,
    required this.previousTransactions,
  });
}
