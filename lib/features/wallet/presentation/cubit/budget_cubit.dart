import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final WalletRepoImpl walletRepo;

  DateTime? _lastStart;
  DateTime? _lastEnd;

  BudgetCubit({required this.walletRepo}) : super(BudgetInitial());

  Future<void> loadBudgetStats({
    required DateTime start,
    required DateTime end,
  }) async {
    _lastStart = start;
    _lastEnd = end;
    emit(BudgetLoading());
    try {
      final stats = await walletRepo.getBudgetStats(start: start, end: end);
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
    if (_lastStart != null && _lastEnd != null) {
      final stats = await walletRepo.getBudgetStats(
        start: _lastStart!,
        end: _lastEnd!,
      );
      emit(BudgetStatsLoaded(stats));
    }
  }
}
