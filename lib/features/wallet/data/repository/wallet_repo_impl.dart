import 'package:fn_tracker/features/features.dart';

abstract class WalletRepoImpl {
  Future<BudgetModel> createBudget({required BudgetModel budget});
  Future<BudgetModel> updateBudget({
    required BudgetModel budget,
    String? effectiveDayKey,
    bool replaceAll = false,
  });
  Future<void> deleteBudget(String id);
  Future<BudgetStatModel> getBudgetStats({
    required String startDayKey,
    required String endDayKey,
  });
  Future<List<BudgetHistoryEntry>> getBudgetHistory(String budgetId);
  Future<void> addBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  });
  Future<void> updateBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  });
  Future<void> deleteBudgetHistoryEntry({
    required String budgetId,
    required String entryId,
  });

  /// Создаёт первую запись в истории, если её нет (миграция старых бюджетов).
  Future<void> ensureBudgetHistoryIfEmpty({
    required String budgetId,
    required BudgetModel budget,
  });

  Future<WalletModel> addWallet({required WalletModel wallet});
  Future<WalletModel> updateWallet({required WalletModel wallet});
  Future<void> deleteWallet(String id, {required bool deleteTransactions});
  Future<List<WalletModel>> getWallets();
  Future<void> setDefaultWallet(String walletId);

  Future<GoalsModel> getGoals();
  Future<GoalModel> createGoal({required GoalModel goal});
  Future<GoalModel> updateGoal({required GoalModel goal});
  Future<void> deleteGoal(String id, {required bool deleteTransactions});

  Future<List<ScheduledPaymentModel>> getScheduledPayments();
  Future<ScheduledPaymentModel> createScheduledPayment({
    required ScheduledPaymentModel payment,
  });
  Future<ScheduledPaymentModel> updateScheduledPayment({
    required ScheduledPaymentModel payment,
  });
  Future<void> deleteScheduledPayment(String id);
}
