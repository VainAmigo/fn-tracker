import 'package:flutter/widgets.dart';

/// Локаль для [SpeechToText.listen] из текущей локали приложения.
String speechRecognitionLocaleId(BuildContext context) {
  final locale = Localizations.localeOf(context);
  final country = locale.countryCode;
  if (country != null && country.isNotEmpty) {
    return '${locale.languageCode}_${country.toUpperCase()}';
  }
  return switch (locale.languageCode.toLowerCase()) {
    'ru' => 'ru_RU',
    'ky' => 'ky_KG',
    'en' => 'en_US',
    _ => 'en_US',
  };
}
