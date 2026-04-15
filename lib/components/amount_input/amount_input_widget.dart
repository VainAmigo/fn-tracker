import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/utils/expression_evaluator.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Блок ввода суммы с кастомной клавиатурой.
///
/// Переиспользуемый компонент. Объединяет [AmountDisplay] и [AmountKeyboard].
/// При [enableCalculator] добавляет операторы + - * / и вычисление в реальном времени.
class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.currency,
    this.initialAmount = '',
    this.onAmountChanged,
    this.label,
    this.enableCalculator = false,
  });

  /// Валюта для отображения символа и форматирования.
  final Currency currency;

  /// Начальное значение суммы.
  final String initialAmount;

  /// Вызывается при изменении суммы (сырая строка или результат вычисления).
  final void Function(String amount)? onAmountChanged;

  /// Подпись над полем.
  final String? label;

  /// Включить режим калькулятора с операторами + - * /.
  final bool enableCalculator;

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late String _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
  }

  @override
  void didUpdateWidget(AmountInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAmount != widget.initialAmount) {
      _amount = widget.initialAmount;
    }
  }

  void _onKeyPressed(String key) {
    final decimalSep = widget.currency.decimalSeparator ==
            DecimalSeparator.comma
        ? ','
        : '.';
    final nextAmount = AmountInputLogic.applyKey(
      currentAmount: _amount,
      key: key,
      decimalPlaces: widget.currency.decimalPlaces,
      decimalSeparator: decimalSep,
      enableCalculator: widget.enableCalculator,
    );
    if (nextAmount != _amount) {
      setState(() {
        _amount = nextAmount;
      });
      _notifyAmountChanged();
    }
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(widget.currency.decimalPlaces);
  }

  String _formatResultForDisplay(double value) {
    final str = _formatResult(value);
    if (widget.currency.decimalSeparator == DecimalSeparator.comma) {
      return str.replaceAll('.', ',');
    }
    return str;
  }

  void _notifyAmountChanged() {
    widget.onAmountChanged?.call(_amount);
  }

  @override
  Widget build(BuildContext context) {
    final hasOperator = widget.enableCalculator &&
        ExpressionEvaluator.hasOperator(_amount);
    String? computedResult;
    if (hasOperator) {
      final r = ExpressionEvaluator.evaluate(_amount);
      computedResult = r != null ? _formatResultForDisplay(r) : null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AmountDisplay(
          amount: _amount,
          currency: widget.currency,
          label: widget.label ?? context.l10n.enterAmount,
          expression: hasOperator ? _amount : null,
          computedResult: computedResult,
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        AmountKeyboard(
          onKeyPressed: _onKeyPressed,
          showOperators: widget.enableCalculator,
        ),
      ],
    );
  }
}
