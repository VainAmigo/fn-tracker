import 'package:fn_tracker/core/utils/date_keys_extention.dart';
import 'package:fn_tracker/core/utils/month.dart';

/// Тип периода, выбранного в пикере (год / месяц / неделя).
/// Используется для передачи выбранного диапазона на экраны.
sealed class DatePickerPeriod {
  const DatePickerPeriod();

  /// Начало периода (dayKey для запросов).
  String get startDayKey;

  /// Конец периода (dayKey для запросов).
  String get endDayKey;

  /// Ключи периодов для тренда (например, месяцы). Для аналитики.
  List<String> get periodKeysForTrend;
}

/// Выбран год.
final class YearlyPeriod extends DatePickerPeriod {
  const YearlyPeriod(this.year);

  final int year;

  @override
  String get startDayKey => DateTime(year, 1, 1).dayKey;

  @override
  String get endDayKey => DateTime(year, 12, 31).dayKey;

  @override
  List<String> get periodKeysForTrend => List.generate(
        12,
        (i) => DateTime(year, i + 1, 1).periodKey,
      );
}

/// Выбран месяц.
final class MonthlyPeriod extends DatePickerPeriod {
  const MonthlyPeriod({required this.year, required this.month});

  final int year;
  final Month month;

  @override
  String get startDayKey {
    final start = DateTime(year, month.value, 1);
    return start.dayKey;
  }

  @override
  String get endDayKey {
    final end = DateTime(year, month.value + 1, 0, 23, 59, 59);
    return end.dayKey;
  }

  @override
  List<String> get periodKeysForTrend => [DateTime(year, month.value, 1).periodKey];
}

/// Выбрана неделя (понедельник — воскресенье).
final class WeeklyPeriod extends DatePickerPeriod {
  const WeeklyPeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  String get startDayKey => start.dayKey;

  @override
  String get endDayKey => end.dayKey;

  @override
  List<String> get periodKeysForTrend => [start.periodKey];
}
