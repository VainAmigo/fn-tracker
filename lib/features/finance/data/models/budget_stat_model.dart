import 'package:fn_tracker/features/features.dart';

class CategorySpending {
  final CategoryModel category;
  final double amount;
  /// Абсолютный лимит в валюте (null если лимита нет).
  final double? resolvedLimit;

  const CategorySpending({
    required this.category,
    required this.amount,
    this.resolvedLimit,
  });
}

class BudgetStatModel {
  final BudgetModel? budget;
  /// Сумма бюджета на просматриваемый месяц (из истории).
  final double budgetAmount;
  final List<TransactionModel> transactions;
  final double totalForPeriod;
  final double allocatedLimits;
  final double remainingAfterLimits;
  final List<CategorySpending> categorySpending;
  final List<BudgetHistoryEntry> history;

  const BudgetStatModel({
    required this.budget,
    required this.budgetAmount,
    required this.transactions,
    required this.totalForPeriod,
    required this.allocatedLimits,
    required this.remainingAfterLimits,
    required this.categorySpending,
    this.history = const [],
  });
}
