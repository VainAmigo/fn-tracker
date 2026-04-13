part of 'goals_cubit.dart';

sealed class GoalsState {}

class GoalsInitial extends GoalsState {}

class GoalsLoading extends GoalsState {}

class GoalsEmpty extends GoalsState {}

class GoalsLoaded extends GoalsState {
  final GoalsModel goalsModel;

  GoalsLoaded({required this.goalsModel});
}

class GoalsError extends GoalsState {
  final String message;

  GoalsError({required this.message});
}

class GoalsCompleteGoalSuccess extends GoalsState {
  final TransactionModel transaction;

  GoalsCompleteGoalSuccess({required this.transaction});
}
