import 'package:fn_tracker/core/utils/month.dart';

/// Утилиты для получения диапазонов дат.
class MonthRangeUtils {
  MonthRangeUtils._();

  /// Начало и конец календарного месяца для заданного года и месяца.
  static ({DateTime start, DateTime end}) rangeFor(int year, Month month) {
    final start = DateTime(year, month.value, 1);
    final end = DateTime(year, month.value + 1, 0, 23, 59, 59);
    return (start: start, end: end);
  }

  /// Начало и конец календарного месяца для любой даты внутри него.
  static ({DateTime start, DateTime end}) rangeFromDateTime(DateTime date) {
    return rangeFor(date.year, Month.fromDateTime(date));
  }

  /// Последние 7 дней (сегодня − 6 дней ... сегодня 23:59:59).
  static ({DateTime start, DateTime end}) lastWeek() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 6);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return (start: start, end: end);
  }

  /// Текущий календарный месяц.
  static ({DateTime start, DateTime end}) currentMonth() {
    final now = DateTime.now();
    return rangeFor(now.year, Month.fromValue(now.month));
  }

  /// Последние [count] месяцев (включая текущий).
  static ({DateTime start, DateTime end}) lastMonths(int count) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (count - 1));
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return (start: start, end: end);
  }
}
