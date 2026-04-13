import 'package:flutter/widgets.dart';
import 'package:fn_tracker/core/utils/month.dart';

extension DateFormattingExtension on DateTime {
  /// October 21
  String formatMonthDay(BuildContext context) {
    final monthName = Month.fromValue(month).localizedName(context);
    return '$monthName $day';
  }

  /// 21 OCT 2025
  String formatDayMonthYearUpper(BuildContext context) {
    final monthName = Month.fromValue(month).localizedShortName(context);
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
