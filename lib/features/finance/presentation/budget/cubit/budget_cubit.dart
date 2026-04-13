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
      List<BudgetHistoryEntry> history = [];
      if (stats.budget != null) {
        await financeRepo.ensureBudgetHistoryIfEmpty(
          budgetId: stats.budget!.id,
          budget: stats.budget!,
        );
        history = await financeRepo.getBudgetHistory(stats.budget!.id);
      }
      emit(BudgetStatsLoaded(stats, history));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> createBudget({required BudgetModel budget}) async {
    await _executeWithReload(() => financeRepo.createBudget(budget: budget));
  }

  Future<void> updateBudget({
    required BudgetModel budget,
    String? effectiveDayKey,
    bool replaceAll = false,
  }) async {
    await _executeWithReload(() => financeRepo.updateBudget(
          budget: budget,
          effectiveDayKey: effectiveDayKey,
          replaceAll: replaceAll,
        ));
  }

  Future<void> deleteBudget(String id) async {
    await _executeWithReload(() => financeRepo.deleteBudget(id));
  }

  Future<void> addBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  }) async {
    await _executeWithReload(() => financeRepo.addBudgetHistoryEntry(
          budgetId: budgetId,
          entry: entry,
        ));
  }

  Future<void> updateBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  }) async {
    await _executeWithReload(() => financeRepo.updateBudgetHistoryEntry(
          budgetId: budgetId,
          entry: entry,
        ));
  }

  Future<void> deleteBudgetHistoryEntry({
    required String budgetId,
    required String entryId,
  }) async {
    await _executeWithReload(() => financeRepo.deleteBudgetHistoryEntry(
          budgetId: budgetId,
          entryId: entryId,
        ));
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
      List<BudgetHistoryEntry> history = [];
      if (stats.budget != null) {
        history = await financeRepo.getBudgetHistory(stats.budget!.id);
      }
      emit(BudgetStatsLoaded(stats, history));
    }
  }
}
