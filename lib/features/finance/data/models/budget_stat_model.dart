import 'package:fn_tracker/features/features.dart';

class CategorySpending {
  final CategoryModel category;
  final double amount;

  const CategorySpending({required this.category, required this.amount});
}

class BudgetStatModel {
  final BudgetModel? budget;
  final List<TransactionModel> transactions;
  final double totalForPeriod;
  final List<CategorySpending> categorySpending;

  const BudgetStatModel({
    required this.budget,
    required this.transactions,
    required this.totalForPeriod,
    required this.categorySpending,
  });
}
