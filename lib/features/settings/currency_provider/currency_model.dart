// lib/models/currency.dart
enum SymbolPosition { left, leftWithSpace, right, rightWithSpace }

enum DecimalSeparator { comma, point }

enum ThousandsSeparator { comma, point, space, none }

class Currency {
  final String code;
  final String symbol;
  final SymbolPosition symbolPosition;
  final DecimalSeparator decimalSeparator;
  final ThousandsSeparator thousandsSeparator;
  final int decimalPlaces;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.symbolPosition,
    required this.decimalSeparator,
    required this.thousandsSeparator,
    required this.decimalPlaces,
    required this.name,
  });

  /// Найти валюту по коду.
  static Currency fromCode(String code) {
    return availableCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => availableCurrencies.first,
    );
  }

  static const List<Currency> availableCurrencies = [
    Currency(
      code: 'USD',
      symbol: '\$',
      symbolPosition: SymbolPosition.left,
      decimalSeparator: DecimalSeparator.point,
      thousandsSeparator: ThousandsSeparator.comma,
      decimalPlaces: 2,
      name: 'US Dollar',
    ),
    Currency(
      code: 'EUR',
      symbol: '€',
      symbolPosition: SymbolPosition.right,
      decimalSeparator: DecimalSeparator.comma,
      thousandsSeparator: ThousandsSeparator.point,
      decimalPlaces: 2,
      name: 'Euro',
    ),
    Currency(
      code: 'RUB',
      symbol: '₽',
      symbolPosition: SymbolPosition.right,
      decimalSeparator: DecimalSeparator.comma,
      thousandsSeparator: ThousandsSeparator.space,
      decimalPlaces: 2,
      name: 'Russian Ruble',
    ),
    Currency(
      code: 'GBP',
      symbol: '£',
      symbolPosition: SymbolPosition.left,
      decimalSeparator: DecimalSeparator.point,
      thousandsSeparator: ThousandsSeparator.comma,
      decimalPlaces: 2,
      name: 'British Pound',
    ),
    Currency(
      code: 'JPY',
      symbol: '¥',
      symbolPosition: SymbolPosition.left,
      decimalSeparator: DecimalSeparator.point,
      thousandsSeparator: ThousandsSeparator.comma,
      decimalPlaces: 0,
      name: 'Japanese Yen',
    ),
  ];
}
