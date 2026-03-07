import 'package:fn_tracker/features/features.dart';

abstract class WalletRepoImpl {
  Future<BudgetModel?> getBudget();
  Future<BudgetModel> createBudget({required BudgetModel budget});
  Future<BudgetModel> updateBudget({required BudgetModel budget});
  Future<void> deleteBudget(String id);
  Future<BudgetStatModel> getBudgetStats({
    required String periodKey,
  });

  Future<WalletModel> addWallet({required WalletModel wallet});
  Future<WalletModel> updateWallet({required WalletModel wallet});
  Future<void> deleteWallet(String id);
  Future<List<WalletModel>> getWallets();
  Future<void> setDefaultWallet(String walletId);
}
