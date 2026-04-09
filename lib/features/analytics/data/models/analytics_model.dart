import 'package:fn_tracker/features/features.dart';

/// Агрегированная статистика за период.
class AnalyticsModel {
  const AnalyticsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySpending,
    required this.periodSegments,
    required this.daySpending,
  });

  final double totalIncome;
  final double totalExpense;
  final List<CategorySpending> categorySpending;

  /// Сегменты для Bar-диаграммы: 12 месяцев, 31 день или 7 дней недели.
  final List<PeriodSegmentItem> periodSegments;

  /// Дневная разбивка по расходам для heatmap-календаря.
  final List<AnalyticsDaySpending> daySpending;

  double get balance => totalIncome - totalExpense;
}

/// Данные расходов за конкретный день.
class AnalyticsDaySpending {
  const AnalyticsDaySpending({
    required this.date,
    required this.categorySpending,
  });

  final DateTime date;
  final List<CategorySpending> categorySpending;

  double get total =>
      categorySpending.fold<double>(0, (sum, item) => sum + item.amount);
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
