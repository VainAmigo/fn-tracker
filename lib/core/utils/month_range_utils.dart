import 'package:fn_tracker/core/utils/month.dart';

/// Утилиты для получения диапазонов дат.
class MonthRangeUtils {
  MonthRangeUtils._();

  /// Начало и конец календарного месяца для заданного года и месяца.
  static ({DateTime start, DateTime end}) rangeFor(int year, Month month) {
    final start = DateTime(year, month.value, 1);
    final end = month.value == 12
        ? DateTime(year, 12, 31)
        : DateTime(year, month.value + 1, 0);
    return (start: start, end: end);
  }

  /// Начало и конец календарного месяца для любой даты внутри него.
  static ({DateTime start, DateTime end}) rangeFromDateTime(DateTime date) {
    return rangeFor(date.year, Month.fromDateTime(date));
  }

  /// Последние 7 дней (сегодня − 6 дней ... сегодня).
  static ({DateTime start, DateTime end}) lastWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (start: today.subtract(const Duration(days: 7)), end: today);
  }

  /// Текущий календарный месяц.
  static ({DateTime start, DateTime end}) currentMonth() {
    final now = DateTime.now();
    return (
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  /// Последние [count] месяцев (включая текущий).
  static ({DateTime start, DateTime end}) lastMonths(int count) {
    final now = DateTime.now();
    return (
      start: DateTime(now.year, now.month - (count - 1)),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }
}
