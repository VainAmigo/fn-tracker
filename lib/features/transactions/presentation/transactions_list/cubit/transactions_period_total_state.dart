part of 'transactions_period_total_cubit.dart';

sealed class TransactionsPeriodTotalState {}

class TransactionsPeriodTotalInitial extends TransactionsPeriodTotalState {}

class TransactionsPeriodTotalLoading extends TransactionsPeriodTotalState {}

class TransactionsPeriodTotalLoaded extends TransactionsPeriodTotalState {
  final double total;

  TransactionsPeriodTotalLoaded({required this.total});
}

class TransactionsPeriodTotalError extends TransactionsPeriodTotalState {
  final String message;

  TransactionsPeriodTotalError({required this.message});
}