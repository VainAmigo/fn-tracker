part of 'transactions_cubit.dart';

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