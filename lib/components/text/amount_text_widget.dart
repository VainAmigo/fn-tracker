import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:provider/provider.dart';

/// Простой виджет для отображения суммы с символом валюты в правильной позиции.
///
/// Отображает текст вида "$ 200.00" или "200,00 €" в зависимости от [Currency.symbolPosition].
/// Стиль текста настраивается через [style].
///
/// Пример:
/// ```dart
/// AmountTextWidget(
///   amount: 200.0,
///   style: AppTextStyles.text16w400(context),
/// )
/// ```
class AmountTextWidget extends StatelessWidget {
  const AmountTextWidget({
    super.key,
    required this.amount,
    this.currency,
    this.sign,
    this.style,
    this.decimalPlaces = 2,
  });

  final double amount;

  /// Явная валюта (приоритет над [CurrencyProvider]).
  final Currency? currency;

  /// Символ валюты (если нет [currency] и нет [CurrencyProvider]).
  final String? sign;

  /// Стиль текста. Можно передать [AppTextStyles], например:
  /// `AppTextStyles.text16w400(context)` или `AppTextStyles.amountDisplayAmount(context)`.
  final TextStyle? style;

  /// Количество знаков после запятой (только при отсутствии currency).
  final int decimalPlaces;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveCurrency = currency ?? _currencyFromContext(context);

    String formattedText;
    if (effectiveCurrency != null) {
      final formatter = CurrencyFormatter(effectiveCurrency);
      formattedText = formatter.format(amount);
    } else {
      final formatted = AmountFormatter.formatWithParts(
        amount,
        decimalPlaces: decimalPlaces,
      );
      final symbol = sign ?? '';
      formattedText = symbol.isNotEmpty
          ? '$symbol ${formatted.full}'
          : formatted.full;
    }

    // Убираем .00 или ,00 для целых чисел (0{1,2} — только дробная часть, не ,000)
    if (amount == amount.truncateToDouble()) {
      formattedText = formattedText.replaceAll(
        RegExp(r'[.,]0{1,2}(?=\s|$|[^\d])'),
        '',
      );
    }

    final effectiveStyle = style ?? theme.textTheme.bodyLarge;

    return Text(formattedText, style: effectiveStyle);
  }

  Currency? _currencyFromContext(BuildContext context) {
    try {
      return context.watch<CurrencyProvider>().currency;
    } catch (_) {
      return null;
    }
  }
}
