import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:provider/provider.dart';

/// Виджет для отображения суммы с разным цветом для целой и дробной части.
///
/// Целая часть отображается белым (onSurface), дробная часть и символ
/// валюты — серым (onSecondary).
///
/// Если [currency] задан — используется [CurrencyFormatter] и [currency.symbol].
/// Иначе при наличии [CurrencyProvider] берётся валюта из провайдера.
/// Если нет провайдера — используются [sign] и [AmountFormatter] с [decimalPlaces].
class AmountWithSignWidget extends StatelessWidget {
  const AmountWithSignWidget({
    super.key,
    required this.amount,
    this.sign,
    this.currency,
    this.preset = AmountTextPreset.large,
    this.decimalPlaces = 2,
  });

  final double amount;

  /// Символ валюты (используется, если нет [currency] и нет [CurrencyProvider]).
  final String? sign;

  /// Явная валюта (приоритет над [CurrencyProvider]).
  final Currency? currency;

  /// Пресет размера текста.
  final AmountTextPreset preset;

  /// Количество знаков после запятой (только при отсутствии currency).
  final int decimalPlaces;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveCurrency = currency ?? _currencyFromContext(context);

    final FormattedAmount formatted;
    final String symbol;
    final bool symbolBeforeNumber;

    if (effectiveCurrency != null) {
      final formatter = CurrencyFormatter(effectiveCurrency);
      formatted = formatter.formatWithParts(amount);
      symbol = effectiveCurrency.symbol;
      symbolBeforeNumber = effectiveCurrency.symbolPosition ==
              SymbolPosition.left ||
          effectiveCurrency.symbolPosition == SymbolPosition.leftWithSpace;
    } else {
      formatted = AmountFormatter.formatWithParts(
        amount,
        decimalPlaces: decimalPlaces,
      );
      symbol = sign ?? '';
      symbolBeforeNumber = false;
    }

    final fontSize = amountTextSize(preset);
    final decimalFontSize = amountDecimalTextSize(preset);

    final secondaryStyle = TextStyle(
      color: colorScheme.onSecondary,
      fontFamily: theme.textTheme.bodyLarge?.fontFamily,
      fontSize: decimalFontSize,
      fontWeight: FontWeight.w400,
    );

    final primaryStyle = TextStyle(
      color: colorScheme.onSurface,
      fontFamily: theme.textTheme.bodyLarge?.fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );

    final children = <TextSpan>[];
    final addSpaceBeforeSymbol = effectiveCurrency?.symbolPosition ==
        SymbolPosition.rightWithSpace;
    final addSpaceAfterSymbol = effectiveCurrency?.symbolPosition ==
        SymbolPosition.leftWithSpace;

    if (symbolBeforeNumber && symbol.isNotEmpty) {
      final prefix = addSpaceAfterSymbol ? '$symbol ' : symbol;
      children.add(TextSpan(text: prefix, style: secondaryStyle));
    }
    children.add(TextSpan(text: formatted.integerPart, style: primaryStyle));
    final suffix = symbolBeforeNumber
        ? formatted.decimalPart
        : '${formatted.decimalPart}${addSpaceBeforeSymbol ? ' ' : ''}$symbol';
    children.add(TextSpan(text: suffix, style: secondaryStyle));

    return RichText(
      text: TextSpan(children: children),
    );
  }

  Currency? _currencyFromContext(BuildContext context) {
    try {
      return context.watch<CurrencyProvider>().currency;
    } catch (_) {
      return null;
    }
  }

  /// Пресеты размеров текста для отображения сумм.
  static const double amountTextSmall = 14.0;
  static const double amountTextMedium = 18.0;
  static const double amountTextLarge = 44.0;

  static double amountTextSize(AmountTextPreset preset) {
    return switch (preset) {
      AmountTextPreset.small => amountTextSmall,
      AmountTextPreset.medium => amountTextMedium,
      AmountTextPreset.large => amountTextLarge,
    };
  }
  static double amountDecimalTextSize(AmountTextPreset preset) {
    return switch (preset) {
      AmountTextPreset.small => amountTextSmall,
      AmountTextPreset.medium => amountTextMedium * 0.8,
      AmountTextPreset.large => amountTextLarge * 0.6,
    };
  }
}

/// Пресеты размеров текста для отображения денежных сумм.
enum AmountTextPreset { small, medium, large }
