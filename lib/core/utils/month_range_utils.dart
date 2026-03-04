import 'package:fn_tracker/core/utils/month.dart';

/// Утилиты для получения границ месяца (начало и конец).
class MonthRangeUtils {
  MonthRangeUtils._();

  /// Начало и конец календарного месяца для заданного года и месяца.
  static ({DateTime start, DateTime end}) rangeFor(int year, Month month) {
    final start = DateTime(year, month.value, 1);
    final end = month.value == 12
        ? DateTime(year, 12, 31)
        : DateTime(year, month.value + 1, 0); // последний день месяца
    return (start: start, end: end);
  }

  /// Начало и конец календарного месяца для любой даты внутри него.
  static ({DateTime start, DateTime end}) rangeFromDateTime(DateTime date) {
    return rangeFor(date.year, Month.fromDateTime(date));
  }
}
