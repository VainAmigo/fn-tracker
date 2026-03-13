import 'package:flutter/widgets.dart';
import 'package:fn_tracker/core/utils/month.dart';

extension DateFormattingExtension on DateTime {
  static const List<String> _monthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _monthsShortUpper = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  /// October 21
  String get formatMonthDay {
    final monthName = _monthsFull[month - 1];
    return '$monthName $day';
  }

  /// 21 OCT 2025
  String get formatDayMonthYearUpper {
    final monthName = _monthsShortUpper[month - 1];
    return '$day $monthName $year';
  }

  /// 21.10.2025
  String get formatDotDate {
    final d = day.toString().padLeft(2, '0');
    final m = month.toString().padLeft(2, '0');
    return '$d.$m.$year';
  }

  /// 29 Sep — день и локализованное короткое название месяца (для диапазона недель: 29 Sep - 04 Oct).
  String formatDayMonthShort(BuildContext context) {
    return '$day ${Month.fromValue(month).localizedShortName(context)}';
  }
}
