import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final WalletRepoImpl walletRepo;

  String? _lastPeriodKey;

  BudgetCubit({required this.walletRepo}) : super(BudgetInitial());

  Future<void> loadBudgetStats({
    required String periodKey,
  }) async {
    _lastPeriodKey = periodKey;
    emit(BudgetLoading());
    try {
      final stats = await walletRepo.getBudgetStats(periodKey: periodKey);
      emit(BudgetStatsLoaded(stats));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> createBudget({required BudgetModel budget}) async {
    emit(BudgetLoading());
    try {
      await walletRepo.createBudget(budget: budget);
      await _reloadStats();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> updateBudget({required BudgetModel budget}) async {
    emit(BudgetLoading());
    try {
      await walletRepo.updateBudget(budget: budget);
      await _reloadStats();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> deleteBudget(String id) async {
    emit(BudgetLoading());
    try {
      await walletRepo.deleteBudget(id);
      await _reloadStats();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _reloadStats() async {
    if (_lastPeriodKey != null) {
      final stats = await walletRepo.getBudgetStats(periodKey: _lastPeriodKey!);
      emit(BudgetStatsLoaded(stats));
    }
  } 
}
