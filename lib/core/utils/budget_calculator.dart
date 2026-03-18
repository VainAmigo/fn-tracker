import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

/// Расчёт бюджета за период с учётом истории изменений.
class BudgetCalculator {
  BudgetCalculator._();

  /// Последняя запись, действующая на конец периода.
  /// Используется для Donut: бюджет = amount из этой записи, приведённый к периоду.
  static BudgetHistoryEntry? latestEntryForPeriod(
    List<BudgetHistoryEntry> history,
    DatePickerPeriod period,
  ) {
    final endKey = period.endDayKey;
    final applicable = history
        .where((e) => e.effectiveDayKey.compareTo(endKey) <= 0)
        .toList()
      ..sort((a, b) => b.effectiveDayKey.compareTo(a.effectiveDayKey));
    return applicable.isEmpty ? null : applicable.first;
  }

  /// Суммарный бюджет за период с учётом всех изменений в истории.
  static double budgetForPeriod(
    List<BudgetHistoryEntry> history,
    DatePickerPeriod period,
  ) {
    if (history.isEmpty) return 0;

    var total = 0.0;
    var current = period.startDate;
    final end = period.endDate;

    while (!current.isAfter(end)) {
      final key = current.dayKey;
      final applicable = history
          .where((e) => e.effectiveDayKey.compareTo(key) <= 0)
          .toList()
        ..sort((a, b) => b.effectiveDayKey.compareTo(a.effectiveDayKey));
      if (applicable.isNotEmpty) {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        total += applicable.first.amount / daysInMonth;
      }
      current = current.add(const Duration(days: 1));
    }
    return total;
  }

  /// Лимит бюджета для каждого бара графика.
  /// Линия = бюджет периода (11 666 для недели, 50 000 для месяца).
  /// При смене бюджета в истории — ступенчатая линия (50k → 30k).
  static List<double> chartBudgetLimits(
    List<BudgetHistoryEntry> history,
    DatePickerPeriod period,
  ) {
    return switch (period) {
      YearlyPeriod(:final year) => _yearlyChartLimits(history, year, period),
      MonthlyPeriod(:final year, :final month) =>
        _monthlyChartLimits(history, year, month, period),
      WeeklyPeriod(:final start, :final end) =>
        _weeklyChartLimits(history, start, end, period),
    };
  }

  /// Бюджет периода для даты: entry.amount, приведённый к выбранному периоду.
  static double _periodBudgetForDay(
    List<BudgetHistoryEntry> history,
    DateTime date,
    DatePickerPeriod period,
  ) {
    if (history.isEmpty) return 0;
    final key = date.dayKey;
    final applicable = history
        .where((e) => e.effectiveDayKey.compareTo(key) <= 0)
        .toList()
      ..sort((a, b) => b.effectiveDayKey.compareTo(a.effectiveDayKey));
    if (applicable.isEmpty) return 0;
    return BudgetDisplayUtils.budgetForDisplayPeriod(
      applicable.first.amount,
      period,
    );
  }

  static List<double> _yearlyChartLimits(
    List<BudgetHistoryEntry> history,
    int year,
    DatePickerPeriod period,
  ) {
    final result = <double>[];
    for (int m = 1; m <= 12; m++) {
      final midMonth = DateTime(year, m, 15);
      result.add(_periodBudgetForDay(history, midMonth, period));
    }
    return result;
  }

  static List<double> _monthlyChartLimits(
    List<BudgetHistoryEntry> history,
    int year,
    Month month,
    DatePickerPeriod period,
  ) {
    final start = DateTime(year, month.value, 1);
    final end = DateTime(year, month.value + 1, 0);
    final barCount = end.difference(start).inDays + 1;
    final result = <double>[];
    for (int i = 0; i < barCount; i++) {
      final d = start.add(Duration(days: i));
      result.add(_periodBudgetForDay(history, d, period));
    }
    return result;
  }

  static List<double> _weeklyChartLimits(
    List<BudgetHistoryEntry> history,
    DateTime start,
    DateTime end,
    DatePickerPeriod period,
  ) {
    final barCount = end.difference(start).inDays + 1;
    final result = <double>[];
    for (int i = 0; i < barCount; i++) {
      final d = start.add(Duration(days: i));
      result.add(_periodBudgetForDay(history, d, period));
    }
    return result;
  }

  /// Траты по барам для графика (из транзакций).
  static List<double> chartSpendingValues(
    List<TransactionModel> transactions,
    DatePickerPeriod period,
  ) {
    return switch (period) {
      YearlyPeriod(:final year) => _yearlySpendingValues(year, transactions),
      MonthlyPeriod(:final year, :final month) =>
        _monthlySpendingValues(year, month, transactions),
      WeeklyPeriod(:final start, :final end) =>
        _weeklySpendingValues(start, end, transactions),
    };
  }

  static List<double> _yearlySpendingValues(
    int year,
    List<TransactionModel> transactions,
  ) {
    final spendingByDayKey = _spendingByDayKey(transactions);
    final result = <double>[];
    for (int m = 1; m <= 12; m++) {
      final barStart = DateTime(year, m, 1);
      final barEnd = DateTime(year, m + 1, 0);
      result.add(_spendingForDateRange(spendingByDayKey, barStart, barEnd));
    }
    return result;
  }

  static List<double> _monthlySpendingValues(
    int year,
    Month month,
    List<TransactionModel> transactions,
  ) {
    final start = DateTime(year, month.value, 1);
    final end = DateTime(year, month.value + 1, 0);
    final barCount = end.difference(start).inDays + 1;
    final spendingByDayKey = _spendingByDayKey(transactions);
    final result = <double>[];
    for (int i = 0; i < barCount; i++) {
      final d = start.add(Duration(days: i));
      result.add(spendingByDayKey[d.dayKey] ?? 0);
    }
    return result;
  }

  static List<double> _weeklySpendingValues(
    DateTime start,
    DateTime end,
    List<TransactionModel> transactions,
  ) {
    final barCount = end.difference(start).inDays + 1;
    final spendingByDayKey = _spendingByDayKey(transactions);
    final result = <double>[];
    for (int i = 0; i < barCount; i++) {
      final d = start.add(Duration(days: i));
      result.add(spendingByDayKey[d.dayKey] ?? 0);
    }
    return result;
  }

  static Map<String, double> _spendingByDayKey(List<TransactionModel> transactions) {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        map[t.dayKey] = (map[t.dayKey] ?? 0) + t.amount;
      }
    }
    return map;
  }

  static double _spendingForDateRange(
    Map<String, double> spendingByDayKey,
    DateTime start,
    DateTime end,
  ) {
    var total = 0.0;
    var d = start;
    while (!d.isAfter(end)) {
      total += spendingByDayKey[d.dayKey] ?? 0;
      d = d.add(const Duration(days: 1));
    }
    return total;
  }
}
