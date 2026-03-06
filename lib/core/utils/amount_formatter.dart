import 'package:fn_tracker/features/features.dart';

/// Утилита для форматирования денежных сумм.
class AmountFormatter {
  AmountFormatter._();

  /// Форматирует сумму с заданными параметрами.
  ///
  /// [amount] — число для форматирования.
  /// [decimalPlaces] — количество знаков после запятой (по умолчанию 2).
  /// [thousandsSeparator] — разделитель тысяч (по умолчанию пробел).
  /// [decimalSeparator] — разделитель дробной части (по умолчанию точка).
  static String format(
    double amount, {
    int decimalPlaces = 2,
    String thousandsSeparator = ' ',
    String decimalSeparator = '.',
  }) {
    final sign = amount.isNegative ? '-' : '';
    final absAmount = amount.abs();

    final integerPart = absAmount.truncate();
    final decimalPart = (absAmount - integerPart)
        .toStringAsFixed(decimalPlaces)
        .substring(2)
        .padRight(decimalPlaces, '0');

    final integerStr = _addThousandsSeparator(
      integerPart.toString(),
      thousandsSeparator,
    );

    return '$sign$integerStr$decimalSeparator$decimalPart';
  }

  /// Разбивает отформатированную сумму на целую и дробную части.
  ///
  /// Возвращает [FormattedAmount] с [integerPart] (например "120 586")
  /// и [decimalPart] (например ".00").
  static FormattedAmount formatWithParts(
    double amount, {
    int decimalPlaces = 2,
    String thousandsSeparator = ' ',
    String decimalSeparator = '.',
  }) {
    final formatted = format(
      amount,
      decimalPlaces: decimalPlaces,
      thousandsSeparator: thousandsSeparator,
      decimalSeparator: decimalSeparator,
    );

    final decimalIndex = formatted.indexOf(decimalSeparator);
    if (decimalIndex >= 0) {
      return FormattedAmount(
        integerPart: formatted.substring(0, decimalIndex),
        decimalPart: formatted.substring(decimalIndex),
      );
    }
    return FormattedAmount(integerPart: formatted, decimalPart: '');
  }

  static String _addThousandsSeparator(String number, String separator) {
    if (number.startsWith('-')) {
      return '-${_addThousandsSeparator(number.substring(1), separator)}';
    }
    final buffer = StringBuffer();
    var count = 0;
    for (var i = number.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(number[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }


  static String formatWithDots(String left, String right) {
    return '$left • $right';
  }
}

/// Результат форматирования суммы с разделением на части.
class FormattedAmount {
  const FormattedAmount({required this.integerPart, required this.decimalPart});

  /// Целая часть (например "120 586").
  final String integerPart;

  /// Дробная часть включая разделитель (например ".00").
  final String decimalPart;

  /// Полная строка суммы.
  String get full => '$integerPart$decimalPart';
}

/// Форматтер сумм с учётом настроек валюты.
class CurrencyFormatter {
  CurrencyFormatter(this.currency);

  final Currency currency;

  /// Форматирует сумму согласно настройкам валюты.
  String format(double amount) {
    final formatted = formatWithParts(amount);
    final formattedNumber = formatted.full;

    return switch (currency.symbolPosition) {
      SymbolPosition.left => '${currency.symbol}$formattedNumber',
      SymbolPosition.leftWithSpace => '${currency.symbol} $formattedNumber',
      SymbolPosition.right => '$formattedNumber${currency.symbol}',
      SymbolPosition.rightWithSpace => '$formattedNumber ${currency.symbol}',
    };
  }

  /// Форматирует сумму с разбиением на целую и дробную части (без символа валюты).
  FormattedAmount formatWithParts(double amount) {
    final rounded = amount.toStringAsFixed(currency.decimalPlaces);
    final parts = rounded.split('.');

    final intPart = parts[0];
    final buffer = StringBuffer();

    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(_getThousandsSeparator());
      }
      buffer.write(intPart[i]);
    }

    final integerPart = buffer.toString();
    final decimalPart = currency.decimalPlaces > 0
        ? _getDecimalSeparator() + parts[1]
        : '';

    return FormattedAmount(integerPart: integerPart, decimalPart: decimalPart);
  }

  /// Парсит отформатированную строку в число.
  double parse(String formattedValue) {
    String cleanValue = formattedValue.replaceAll(currency.symbol, '').trim();
    cleanValue = cleanValue.replaceAll(_getThousandsSeparator(), '');
    if (_getDecimalSeparator() != '.') {
      cleanValue = cleanValue.replaceAll(_getDecimalSeparator(), '.');
    }
    return double.tryParse(cleanValue) ?? 0.0;
  }

  String _getThousandsSeparator() {
    return switch (currency.thousandsSeparator) {
      ThousandsSeparator.comma => ',',
      ThousandsSeparator.point => '.',
      ThousandsSeparator.space => ' ',
      ThousandsSeparator.none => '',
    };
  }

  String _getDecimalSeparator() {
    return switch (currency.decimalSeparator) {
      DecimalSeparator.comma => ',',
      DecimalSeparator.point => '.',
    };
  }
}
