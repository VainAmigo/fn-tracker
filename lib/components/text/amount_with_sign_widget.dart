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
///
/// При [animateAmountChanges] == true значение [amount] плавно интерполируется при
/// обновлении из родителя (удобно для карточек вроде [HomeTopActionWidget]).
class AmountWithSignWidget extends StatefulWidget {
  const AmountWithSignWidget({
    super.key,
    required this.amount,
    this.sign,
    this.currency,
    this.preset = AmountTextPreset.large,
    this.decimalPlaces = 2,
    this.animateAmountChanges = true,
    this.amountChangeDuration = const Duration(milliseconds: 450),
    this.amountChangeCurve = Curves.easeOutCubic,
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

  /// Плавный переход при смене [amount] (только если виджет уже был в дереве).
  final bool animateAmountChanges;

  final Duration amountChangeDuration;

  final Curve amountChangeCurve;

  @override
  State<AmountWithSignWidget> createState() => _AmountWithSignWidgetState();

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

class _AmountWithSignWidgetState extends State<AmountWithSignWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _amountController = AnimationController(
    vsync: this,
    duration: widget.amountChangeDuration,
  );

  late CurvedAnimation _amountCurve = _makeAmountCurve();

  double _tweenStart = 0;
  double _tweenEnd = 0;

  CurvedAnimation _makeAmountCurve() => CurvedAnimation(
        parent: _amountController,
        curve: widget.amountChangeCurve,
      );

  double _displayAmountNow() {
    final t = _amountCurve.value;
    return _tweenStart + (_tweenEnd - _tweenStart) * t;
  }

  @override
  void initState() {
    super.initState();
    _tweenStart = widget.amount;
    _tweenEnd = widget.amount;
    _amountController.value = 1;
  }

  @override
  void didUpdateWidget(covariant AmountWithSignWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amountChangeDuration != widget.amountChangeDuration) {
      _amountController.duration = widget.amountChangeDuration;
    }
    if (oldWidget.amountChangeCurve != widget.amountChangeCurve) {
      _amountCurve.dispose();
      _amountCurve = _makeAmountCurve();
    }
    if (oldWidget.amount != widget.amount) {
      if (!widget.animateAmountChanges) {
        _tweenStart = widget.amount;
        _tweenEnd = widget.amount;
        _amountController.value = 1;
      } else {
        _tweenStart = _displayAmountNow();
        _tweenEnd = widget.amount;
        _amountController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _amountCurve.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCurrency = widget.currency ?? _currencyFromContext(context);
    return AnimatedBuilder(
      animation: _amountController,
      builder: (context, _) => _buildAmountRichText(
        context,
        displayAmount: _displayAmountNow(),
        effectiveCurrency: effectiveCurrency,
      ),
    );
  }

  Widget _buildAmountRichText(
    BuildContext context, {
    required double displayAmount,
    required Currency? effectiveCurrency,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final FormattedAmount formatted;
    final String symbol;
    final bool symbolBeforeNumber;

    if (effectiveCurrency != null) {
      final formatter = CurrencyFormatter(effectiveCurrency);
      formatted = formatter.formatWithParts(displayAmount);
      symbol = effectiveCurrency.symbol;
      symbolBeforeNumber = effectiveCurrency.symbolPosition ==
              SymbolPosition.left ||
          effectiveCurrency.symbolPosition == SymbolPosition.leftWithSpace;
    } else {
      formatted = AmountFormatter.formatWithParts(
        displayAmount,
        decimalPlaces: widget.decimalPlaces,
      );
      symbol = widget.sign ?? '';
      symbolBeforeNumber = false;
    }

    final fontSize = AmountWithSignWidget.amountTextSize(widget.preset);
    final decimalFontSize =
        AmountWithSignWidget.amountDecimalTextSize(widget.preset);

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
}

/// Пресеты размеров текста для отображения денежных сумм.
enum AmountTextPreset { small, medium, large }
