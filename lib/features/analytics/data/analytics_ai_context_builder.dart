import 'dart:convert';

import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/analytics/analytics.dart';

/// Сериализация аналитики для AI и ключ периода (месяц / год / неделя).
abstract final class AnalyticsAiContextBuilder {
  /// Устойчивый ключ: меняется при смене типа периода или выбранного диапазона.
  static String periodContextKey(DatePickerPeriod period) {
    return switch (period) {
      YearlyPeriod(:final year) => 'year:$year',
      MonthlyPeriod(:final year, :final month) => 'month:$year-${month.value}',
      WeeklyPeriod(:final start, :final end) =>
        'week:${start.dayKey}_${end.dayKey}',
    };
  }

  static String periodDescription(DatePickerPeriod period) {
    return switch (period) {
      YearlyPeriod(:final year) => 'Year $year',
      MonthlyPeriod(:final year, :final month) =>
        '${month.name} $year',
      WeeklyPeriod(:final start, :final end) =>
        '${start.day}.${start.month}.${start.year} — ${end.day}.${end.month}.${end.year}',
    };
  }

  static String buildJsonString(AnalyticsModel data, DatePickerPeriod period) {
    return jsonEncode(buildMap(data, period));
  }

  static Map<String, Object?> buildMap(
    AnalyticsModel data,
    DatePickerPeriod period,
  ) {
    return {
      'period': {
        'key': periodContextKey(period),
        'description': periodDescription(period),
        'startDayKey': period.startDayKey,
        'endDayKey': period.endDayKey,
      },
      'totals': {
        'income': data.totalIncome,
        'expense': data.totalExpense,
        'balance': data.balance,
      },
      'categorySpending': [
        for (final c in data.categorySpending)
          {
            'categoryName': c.category.name,
            'categoryId': c.category.categoryId,
            'amount': c.amount,
          },
      ],
      'periodSegments': [
        for (final s in data.periodSegments)
          {
            'label': s.label,
            'segmentTotal': s.total,
            'byCategory': [
              for (final c in s.categorySpending)
                {
                  'categoryName': c.category.name,
                  'amount': c.amount,
                },
            ],
          },
      ],
      'daySpending': [
        for (final d in data.daySpending)
          {
            'date': d.date.toIso8601String().split('T').first,
            'dayTotal': d.total,
            'byCategory': [
              for (final c in d.categorySpending.take(12))
                {
                  'categoryName': c.category.name,
                  'amount': c.amount,
                },
            ],
          },
      ],
    };
  }
}
