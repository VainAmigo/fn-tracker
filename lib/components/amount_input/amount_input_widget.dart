import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/utils/expression_evaluator.dart';
import 'package:fn_tracker/features/features.dart';
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
    this.label = 'ENTER AMOUNT',
    this.enableCalculator = false,
  });

  /// Валюта для отображения символа и форматирования.
  final Currency currency;

  /// Начальное значение суммы.
  final String initialAmount;

  /// Вызывается при изменении суммы (сырая строка или результат вычисления).
  final void Function(String amount)? onAmountChanged;

  /// Подпись над полем.
  final String label;

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
    if (widget.enableCalculator && _isOperator(key)) {
      _handleOperator(key);
      return;
    }

    if (key == 'backspace') {
      if (_amount.isNotEmpty) {
        setState(() {
          _amount = _amount.substring(0, _amount.length - 1);
        });
        _notifyAmountChanged();
      }
      return;
    }

    if (key == '.') {
      if (_amount.contains('.') || _amount.contains(',')) return;
      if (widget.enableCalculator && ExpressionEvaluator.hasOperator(_amount)) {
        final lastNumStart = _lastNumberStartIndex();
        if (lastNumStart >= 0) {
          final afterOp = _amount.substring(lastNumStart);
          if (afterOp.contains('.') || afterOp.contains(',')) return;
        }
      }
      final decimalSep = widget.currency.decimalSeparator ==
              DecimalSeparator.comma
          ? ','
          : '.';
      setState(() {
        _amount = _amount.isEmpty ? '0$decimalSep' : '$_amount$decimalSep';
      });
      _notifyAmountChanged();
      return;
    }

    // Digit 0-9
    if (widget.enableCalculator && ExpressionEvaluator.hasOperator(_amount)) {
      final lastNumStart = _lastNumberStartIndex();
      if (lastNumStart >= 0) {
        final afterOp = _amount.substring(lastNumStart);
        if (afterOp.contains('.') || afterOp.contains(',')) {
          final parts = afterOp.split(RegExp(r'[.,]'));
          if (parts.length == 2 &&
              parts[1].length >= widget.currency.decimalPlaces) {
            return;
          }
        } else if (afterOp.replaceAll(RegExp(r'[^0-9]'), '').length >= 12) {
          return;
        }
      }
    } else {
      if (_amount.contains('.') || _amount.contains(',')) {
        final parts = _amount.split(RegExp(r'[.,]'));
        if (parts.length == 2 &&
            parts[1].length >= widget.currency.decimalPlaces) {
          return;
        }
      } else if (_amount.length >= 12) {
        return;
      }
    }

    setState(() {
      if (_amount.isEmpty || _amount == '0') {
        _amount = key == '0' ? '0' : key;
      } else {
        _amount = '$_amount$key';
      }
    });
    _notifyAmountChanged();
  }

  bool _isOperator(String key) =>
      key == '+' || key == '-' || key == '*' || key == '/';

  void _handleOperator(String op) {
    if (_amount.isEmpty) return;
    if (ExpressionEvaluator.hasOperator(_amount)) {
      final lastOpIndex = _lastOperatorIndex();
      if (lastOpIndex != null && lastOpIndex == _amount.length - 1) {
        setState(() => _amount = '${_amount.substring(0, lastOpIndex)}$op');
      } else {
        final result = ExpressionEvaluator.evaluate(_amount);
        if (result != null) {
          final resultStr = _formatResult(result);
          setState(() => _amount = '$resultStr$op');
        } else {
          setState(() => _amount = '$_amount$op');
        }
      }
    } else {
      setState(() => _amount = '$_amount$op');
    }
    _notifyAmountChanged();
  }

  int? _lastOperatorIndex() {
    for (int i = _amount.length - 1; i >= 0; i--) {
      if (_isOperator(_amount[i])) return i;
    }
    return null;
  }

  int _lastNumberStartIndex() {
    final idx = _lastOperatorIndex();
    return idx != null ? idx + 1 : 0;
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
          label: widget.label,
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
