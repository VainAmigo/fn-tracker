import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/transactions/transactions.dart';
import 'package:fn_tracker/features/wallet/wallet.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'goals_state.dart';

class GoalsCubit extends HydratedCubit<GoalsState> {
  final WalletRepoImpl walletRepo;
  final TransactionsRepository transactionsRepo;

  GoalsCubit({
    required this.walletRepo,
    required this.transactionsRepo,
  }) : super(GoalsInitial());

  @override
  String get storagePrefix => 'GoalsCubit';

  @override
  GoalsState? fromJson(Map<String, dynamic> json) {
    final type = json['_type'] as String?;
    return switch (type) {
      'loaded' => GoalsLoaded(
          goalsModel: GoalsModel.fromJson(json['goalsModel'] as Map<String, dynamic>),
        ),
      'empty' => GoalsEmpty(),
      _ => null,
    };
  }

  @override
  Map<String, dynamic>? toJson(GoalsState state) {
    if (state is GoalsLoading ||
        state is GoalsInitial ||
        state is GoalsError ||
        state is GoalsCompleteGoalSuccess) {
      return null; // Do not persist — keep previous cached state
    }
    if (state is GoalsEmpty) return {'_type': 'empty'};
    if (state is GoalsLoaded) {
      return {
        '_type': 'loaded',
        'goalsModel': state.goalsModel.toJson(),
      };
    }
    return null;
  }

  void clearForLogout() => emit(GoalsInitial());

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

  Future<void> completeGoal({required GoalModel goal}) async {
    if (goal.progress <= 0) return;
    emit(GoalsLoading());
    try {
      final now = DateTime.now();
      final transaction = TransactionModel(
        id: '',
        categoryId: '',
        walletId: null,
        goalId: goal.id,
        amount: goal.progress,
        type: TransactionType.expense,
        createdAt: now,
        date: now,
        dayKey: now.dayKey,
        periodKey: now.periodKey,
        note: 'Goal completed: ${goal.name}',
      );
      final created = await transactionsRepo.addTransaction(
        transaction: transaction,
      );
      await walletRepo.updateGoal(
        goal: goal.copyWith(
          isCompleted: true,
          completedAt: now,
          completedAmount: goal.progress,
        ),
      );
      emit(GoalsCompleteGoalSuccess(transaction: created));
      await loadGoals();
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  Future<void> deleteGoal({
    required String goalId,
    required bool deleteTransactions,
  }) async {
    final previous = currentGoals;
    emit(GoalsLoading());
    try {
      await walletRepo.deleteGoal(goalId, deleteTransactions: deleteTransactions);
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
    final visibleGoals = goals.where((g) => !g.isHidden).toList();
    final totalProgress =
        visibleGoals.fold<double>(0, (s, g) => s + g.progress);
    final totalTarget =
        visibleGoals.fold<double>(0, (s, g) => s + g.targetAmount);
    final completedCount = visibleGoals.where((g) => g.isCompleted).length;
    return GoalsModel(
      goals: goals,
      totalGoal: TotalGoalModel(
        totalProgress: totalProgress,
        totalTargetAmount: totalTarget,
        goalsCount: visibleGoals.length,
        completedCount: completedCount,
      ),
    );
  }
}
