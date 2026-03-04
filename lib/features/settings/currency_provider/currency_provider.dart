import 'package:fn_tracker/features/features.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для управления валютой приложения.
class CurrencyProvider extends ChangeNotifier {
  static const String _currencyKey = 'app_currency';

  Currency _currency = Currency.availableCurrencies.first;

  CurrencyProvider() {
    _loadCurrency();
  }

  Currency get currency => _currency;

  /// Загрузить сохранённую валюту из SharedPreferences.
  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_currencyKey);

      if (code != null) {
        _currency = Currency.fromCode(code);
        notifyListeners();
      }
    } catch (_) {
      _currency = Currency.availableCurrencies.first;
    }
  }

  /// Установить валюту.
  Future<void> setCurrency(Currency currency) async {
    if (_currency == currency) return;

    _currency = currency;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);
    } catch (_) {}
  }
}
