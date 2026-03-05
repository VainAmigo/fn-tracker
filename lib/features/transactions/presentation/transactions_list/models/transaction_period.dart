import 'package:flutter/widgets.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/l10n/l10.dart';

enum TransactionPeriod {
  week,
  month,
  threeMonths,
  sixMonths;

  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      week => l10n.week,
      month => _currentMonthName(context),
      threeMonths => l10n.threeMonths,
      sixMonths => l10n.sixMonths,
    };
  }

  ({DateTime start, DateTime end}) get dateRange {
    return switch (this) {
      week => MonthRangeUtils.lastWeek(),
      month => MonthRangeUtils.currentMonth(),
      threeMonths => MonthRangeUtils.lastMonths(3),
      sixMonths => MonthRangeUtils.lastMonths(6),
    };
  }

  static String _currentMonthName(BuildContext context) {
    final month = Month.fromDateTime(DateTime.now());
    final l10n = context.l10n;
    return switch (month) {
      Month.january => l10n.january,
      Month.february => l10n.february,
      Month.march => l10n.march,
      Month.april => l10n.april,
      Month.may => l10n.may,
      Month.june => l10n.june,
      Month.july => l10n.july,
      Month.august => l10n.august,
      Month.september => l10n.september,
      Month.october => l10n.october,
      Month.november => l10n.november,
      Month.december => l10n.december,
    };
  }
}
