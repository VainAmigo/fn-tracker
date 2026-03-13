import 'package:flutter/widgets.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// День недели (1 = понедельник, 7 = воскресенье, ISO 8601).
enum Weekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const Weekday(this.value);

  /// Числовое значение дня (1–7, как [DateTime.weekday]).
  final int value;

  /// Возвращает [Weekday] по числу [weekday] (1–7).
  /// Для невалидного значения возвращает [Weekday.monday].
  static Weekday fromValue(int weekday) {
    if (weekday < 1 || weekday > 7) return Weekday.monday;
    return Weekday.values[weekday - 1];
  }

  /// [Weekday] для переданной даты.
  static Weekday fromDateTime(DateTime date) => fromValue(date.weekday);

  /// Локализованное полное название дня недели.
  String localizedName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      Weekday.monday => l10n.monday,
      Weekday.tuesday => l10n.tuesday,
      Weekday.wednesday => l10n.wednesday,
      Weekday.thursday => l10n.thursday,
      Weekday.friday => l10n.friday,
      Weekday.saturday => l10n.saturday,
      Weekday.sunday => l10n.sunday,
    };
  }

  /// Локализованное краткое название дня (для заголовков календаря).
  String localizedShortName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      Weekday.monday => l10n.mondayShort,
      Weekday.tuesday => l10n.tuesdayShort,
      Weekday.wednesday => l10n.wednesdayShort,
      Weekday.thursday => l10n.thursdayShort,
      Weekday.friday => l10n.fridayShort,
      Weekday.saturday => l10n.saturdayShort,
      Weekday.sunday => l10n.sundayShort,
    };
  }
}
