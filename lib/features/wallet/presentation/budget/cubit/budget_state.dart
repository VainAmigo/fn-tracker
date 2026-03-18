part of 'budget_cubit.dart';

sealed class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetStatsLoaded extends BudgetState {
  final BudgetStatModel stats;
  final List<BudgetHistoryEntry> history;

  BudgetStatsLoaded(this.stats, [List<BudgetHistoryEntry>? history])
      : history = history ?? [];
}

class BudgetError extends BudgetState {
  final String error;

  BudgetError(this.error);
}
