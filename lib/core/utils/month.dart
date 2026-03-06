import 'package:flutter/widgets.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Перечисление месяцев года (1–12).
enum Month {
  january(1),
  february(2),
  march(3),
  april(4),
  may(5),
  june(6),
  july(7),
  august(8),
  september(9),
  october(10),
  november(11),
  december(12);

  const Month(this.value);

  /// Числовое значение месяца (1–12).
  final int value;

  /// Возвращает [Month] по числу [month] (1–12).
  /// Для невалидного значения возвращает [Month.january].
  static Month fromValue(int month) {
    if (month < 1 || month > 12) return Month.january;
    return Month.values[month - 1];
  }

  /// [Month] для переданной даты.
  static Month fromDateTime(DateTime date) => fromValue(date.month);

  /// Локализованное название месяца.
  String localizedName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
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
