part of 'add_transaction_cubit.dart';

sealed class AddTransactionState {}

class AddTransactionInitial extends AddTransactionState {}

class AddTransactionCreating extends AddTransactionState {}

class AddTransactionSuccess extends AddTransactionState {
  final List<TransactionModel> createdTransactions;

  AddTransactionSuccess({required this.createdTransactions});
}

class AddTransactionError extends AddTransactionState {
  final String message;

  AddTransactionError({required this.message});
}
