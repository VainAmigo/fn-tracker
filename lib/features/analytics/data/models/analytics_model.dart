import 'package:fn_tracker/features/features.dart';

/// Агрегированная статистика за период.
class AnalyticsModel {
  const AnalyticsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySpending,
    required this.periodSegments,
  });

  final double totalIncome;
  final double totalExpense;
  final List<CategorySpending> categorySpending;

  /// Сегменты для Bar-диаграммы: 12 месяцев, 31 день или 7 дней недели.
  final List<PeriodSegmentItem> periodSegments;

  double get balance => totalIncome - totalExpense;
}

/// Сегмент периода (день/месяц/день недели).
class PeriodSegmentItem {
  const PeriodSegmentItem({
    required this.label,
    required this.categorySpending,
    this.isInitialVisible = false,
  });

  final String label;
  final List<CategorySpending> categorySpending;
  final bool isInitialVisible;

  double get total =>
      categorySpending.fold<double>(0, (s, c) => s + c.amount);
}
