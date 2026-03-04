/// Перечисление месяцев года (1–12).
enum Month {
  january(1, 'January'),
  february(2, 'February'),
  march(3, 'March'),
  april(4, 'April'),
  may(5, 'May'),
  june(6, 'June'),
  july(7, 'July'),
  august(8, 'August'),
  september(9, 'September'),
  october(10, 'October'),
  november(11, 'November'),
  december(12, 'December');

  const Month(this.value, this.displayName);

  /// Числовое значение месяца (1–12).
  final int value;

  /// Локализованное отображаемое имя месяца.
  final String displayName;

  /// Возвращает [Month] по числу [month] (1–12).
  /// Для невалидного значения возвращает [Month.january].
  static Month fromValue(int month) {
    if (month < 1 || month > 12) return Month.january;
    return Month.values[month - 1];
  }

  /// [Month] для переданной даты.
  static Month fromDateTime(DateTime date) => fromValue(date.month);
}
