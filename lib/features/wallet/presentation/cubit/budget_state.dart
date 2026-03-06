part of 'budget_cubit.dart';

sealed class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetNotFound extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final BudgetModel budget;

  BudgetLoaded(this.budget);
}

class BudgetError extends BudgetState {
  final String error;

  BudgetError(this.error);
}