import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для управления языком приложения
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('ru');

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  /// Загрузить сохранённый язык из SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null) {
        _locale = Locale(localeCode);
        notifyListeners();
      }
    } catch (e) {
      // В случае ошибки используем русский язык по умолчанию
      _locale = const Locale('ru');
    }
  }

  /// Установить язык приложения
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }

  /// Установить язык по коду языка
  Future<void> setLocaleFromCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }

  /// Получить код текущего языка
  String get currentLanguageCode => _locale.languageCode;
}