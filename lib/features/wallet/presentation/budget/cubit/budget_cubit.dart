import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final WalletRepoImpl walletRepo;

  String? _lastStartDayKey;
  String? _lastEndDayKey;

  BudgetCubit({required this.walletRepo}) : super(BudgetInitial());

  Future<void> loadBudgetStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    _lastStartDayKey = startDayKey;
    _lastEndDayKey = endDayKey;
    emit(BudgetLoading());
    try {
      final stats = await walletRepo.getBudgetStats(
        startDayKey: startDayKey,
        endDayKey: endDayKey,
      );
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
    if (_lastStartDayKey != null && _lastEndDayKey != null) {
      final stats = await walletRepo.getBudgetStats(
        startDayKey: _lastStartDayKey!,
        endDayKey: _lastEndDayKey!,
      );
      emit(BudgetStatsLoaded(stats));
    }
  }
}
