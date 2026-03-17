import 'package:fn_tracker/features/features.dart';

abstract class WalletRepoImpl {
  Future<BudgetModel?> getBudget();
  Future<BudgetModel> createBudget({required BudgetModel budget});
  Future<BudgetModel> updateBudget({required BudgetModel budget});
  Future<void> deleteBudget(String id);
  Future<BudgetStatModel> getBudgetStats({
    required String startDayKey,
    required String endDayKey,
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
