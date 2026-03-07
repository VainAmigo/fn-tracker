part of 'budget_cubit.dart';

sealed class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetStatsLoaded extends BudgetState {
  final BudgetStatModel stats;

  BudgetStatsLoaded(this.stats);
}

class BudgetError extends BudgetState {
  final String error;

  BudgetError(this.error);
}
