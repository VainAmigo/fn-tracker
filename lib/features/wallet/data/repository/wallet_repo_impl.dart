import 'package:fn_tracker/features/features.dart';

abstract class WalletRepoImpl {
  Future<BudgetModel?> getBudget();
  Future<BudgetModel> createBudget({required BudgetModel budget});
  Future<BudgetModel> updateBudget({required BudgetModel budget});
  Future<void> deleteBudget(String id);
}
