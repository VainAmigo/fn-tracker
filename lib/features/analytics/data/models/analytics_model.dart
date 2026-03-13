import 'package:fn_tracker/features/features.dart';

/// Агрегированная статистика за период.
class AnalyticsPeriodModel {
  final double totalIncome;
  final double totalExpense;
  final List<CategorySpending> categorySpending;
  final List<DailySpending> weeklySpending;
  final BudgetModel? budget;

  const AnalyticsPeriodModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySpending,
    required this.weeklySpending,
    this.budget,
  });

  double get balance => totalIncome - totalExpense;
}

/// Расходы по одному дню недели (для недельной диаграммы).
class DailySpending {
  final int weekday;
  final List<CategorySpending> categorySpending;

  const DailySpending({required this.weekday, required this.categorySpending});
}
