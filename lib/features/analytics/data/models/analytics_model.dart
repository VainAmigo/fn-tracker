import 'package:fn_tracker/features/features.dart';

/// Агрегированная статистика за период.
class AnalyticsPeriodModel {
  final double totalIncome;
  final double totalExpense;
  final List<CategorySpending> categorySpending;
  final List<MonthlyTrendItem> monthlyTrend;

  const AnalyticsPeriodModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySpending,
    required this.monthlyTrend,
  });

  double get balance => totalIncome - totalExpense;
}

/// Данные по одному месяцу для тренда.
class MonthlyTrendItem {
  final String periodKey;
  final double income;
  final double expense;

  const MonthlyTrendItem({
    required this.periodKey,
    required this.income,
    required this.expense,
  });
}
