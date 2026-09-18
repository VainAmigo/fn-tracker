import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final FinanceRepoImpl financeRepo;

  String? _lastStartDayKey;
  String? _lastEndDayKey;

  BudgetCubit({required this.financeRepo}) : super(BudgetInitial());

  Future<void> loadBudgetStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    _lastStartDayKey = startDayKey;
    _lastEndDayKey = endDayKey;
    emit(BudgetLoading());
    try {
      final stats = await financeRepo.getBudgetStats(
        startDayKey: startDayKey,
        endDayKey: endDayKey,
      );
      emit(BudgetStatsLoaded(stats));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> createBudget({
    required BudgetModel budget,
    required String startMonthKey,
  }) async {
    await _executeWithReload(
      () => financeRepo.createBudget(
        budget: budget,
        startMonthKey: startMonthKey,
      ),
    );
  }

  Future<void> updateBudget({
    required BudgetModel budget,
    required String startMonthKey,
  }) async {
    await _executeWithReload(
      () => financeRepo.updateBudget(
        budget: budget,
        startMonthKey: startMonthKey,
      ),
    );
  }

  Future<void> deleteBudget(String id) async {
    await _executeWithReload(() => financeRepo.deleteBudget(id));
  }

  Future<void> _executeWithReload(Future<void> Function() action) async {
    emit(BudgetLoading());
    try {
      await action();
      await _reloadStats();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _reloadStats() async {
    if (_lastStartDayKey != null && _lastEndDayKey != null) {
      final stats = await financeRepo.getBudgetStats(
        startDayKey: _lastStartDayKey!,
        endDayKey: _lastEndDayKey!,
      );
      emit(BudgetStatsLoaded(stats));
    }
  }
}
