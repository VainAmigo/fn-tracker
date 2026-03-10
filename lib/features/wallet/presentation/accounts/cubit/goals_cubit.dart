import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/wallet/wallet.dart';

part 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final WalletRepoImpl walletRepo;

  GoalsCubit({required this.walletRepo}) : super(GoalsInitial());

  GoalsModel? get _currentGoalsModel =>
      state is GoalsLoaded ? (state as GoalsLoaded).goalsModel : null;

  List<GoalModel> get currentGoals => _currentGoalsModel?.goals ?? [];

  Future<void> loadGoals() async {
    emit(GoalsLoading());
    try {
      final goalsModel = await walletRepo.getGoals();
      if (goalsModel.goals.isEmpty) {
        emit(GoalsEmpty());
      } else {
        emit(GoalsLoaded(goalsModel: goalsModel));
      }
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  Future<void> createGoal({required GoalModel goal}) async {
    final previous = currentGoals;
    emit(GoalsLoading());
    try {
      final created = await walletRepo.createGoal(goal: goal);
      final updated = [created, ...previous];
      emit(GoalsLoaded(goalsModel: _buildGoalsModel(updated)));
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  Future<void> updateGoal({required GoalModel goal}) async {
    final previous = currentGoals;
    emit(GoalsLoading());
    try {
      final updated = await walletRepo.updateGoal(goal: goal);
      final updatedList =
          previous.map((g) => g.id == updated.id ? updated : g).toList();
      emit(GoalsLoaded(goalsModel: _buildGoalsModel(updatedList)));
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  Future<void> deleteGoal({required String goalId}) async {
    final previous = currentGoals;
    emit(GoalsLoading());
    try {
      await walletRepo.deleteGoal(goalId);
      final updatedList = previous.where((g) => g.id != goalId).toList();
      if (updatedList.isEmpty) {
        emit(GoalsEmpty());
      } else {
        emit(GoalsLoaded(goalsModel: _buildGoalsModel(updatedList)));
      }
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  GoalsModel _buildGoalsModel(List<GoalModel> goals) {
    final totalProgress = goals.fold<double>(0, (s, g) => s + g.progress);
    final totalTarget = goals.fold<double>(0, (s, g) => s + g.targetAmount);
    final completedCount = goals.where(
      (g) => g.targetAmount > 0 && g.progress >= g.targetAmount,
    ).length;
    return GoalsModel(
      goals: goals,
      totalGoal: TotalGoalModel(
        totalProgress: totalProgress,
        totalTargetAmount: totalTarget,
        goalsCount: goals.length,
        completedCount: completedCount,
      ),
    );
  }
}
