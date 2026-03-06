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
      month => Month.fromDateTime(DateTime.now()).localizedName(context),
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
}
