import 'package:fn_tracker/core/utils/expression_evaluator.dart';

/// Единая логика обработки ввода суммы с клавиатуры.
class AmountInputLogic {
  AmountInputLogic._();

  static String applyKey({
    required String currentAmount,
    required String key,
    required int decimalPlaces,
    required String decimalSeparator,
    required bool enableCalculator,
  }) {
    if (key == 'backspace') {
      if (currentAmount.isEmpty) return currentAmount;
      return currentAmount.substring(0, currentAmount.length - 1);
    }

    if (_isOperator(key)) {
      if (!enableCalculator) return currentAmount;
      return _handleOperator(
        currentAmount,
        key,
        decimalPlaces: decimalPlaces,
      );
    }

    if (key == '.') {
      return _handleDecimalPoint(
        currentAmount,
        decimalSeparator: decimalSeparator,
        enableCalculator: enableCalculator,
      );
    }

    if (!RegExp(r'^\d$').hasMatch(key)) return currentAmount;
    return _handleDigit(
      currentAmount,
      key,
      decimalPlaces: decimalPlaces,
      enableCalculator: enableCalculator,
    );
  }

  static double parseAmount(String amount) {
    if (amount.isEmpty) return 0;
    if (ExpressionEvaluator.hasOperator(amount)) {
      return ExpressionEvaluator.evaluate(amount) ?? 0;
    }
    return double.tryParse(amount.replaceAll(',', '.')) ?? 0;
  }

  static String _handleDecimalPoint(
    String currentAmount, {
    required String decimalSeparator,
    required bool enableCalculator,
  }) {
    if (enableCalculator && ExpressionEvaluator.hasOperator(currentAmount)) {
      final lastNumStart = _lastNumberStartIndex(currentAmount);
      if (lastNumStart >= 0) {
        final afterOp = currentAmount.substring(lastNumStart);
        if (afterOp.contains('.') || afterOp.contains(',')) return currentAmount;
        if (afterOp.isEmpty) return '${currentAmount}0$decimalSeparator';
        return '$currentAmount$decimalSeparator';
      }
    }

    if (currentAmount.contains('.') || currentAmount.contains(',')) {
      return currentAmount;
    }
    if (currentAmount.isEmpty) return '0$decimalSeparator';
    return '$currentAmount$decimalSeparator';
  }

  static String _handleDigit(
    String currentAmount,
    String key, {
    required int decimalPlaces,
    required bool enableCalculator,
  }) {
    if (enableCalculator && ExpressionEvaluator.hasOperator(currentAmount)) {
      final lastNumStart = _lastNumberStartIndex(currentAmount);
      if (lastNumStart >= 0) {
        final afterOp = currentAmount.substring(lastNumStart);
        if (afterOp.contains('.') || afterOp.contains(',')) {
          final parts = afterOp.split(RegExp(r'[.,]'));
          if (parts.length == 2 && parts[1].length >= decimalPlaces) {
            return currentAmount;
          }
        } else if (afterOp.replaceAll(RegExp(r'[^0-9]'), '').length >= 12) {
          return currentAmount;
        }
      }
    } else {
      if (currentAmount.contains('.') || currentAmount.contains(',')) {
        final parts = currentAmount.split(RegExp(r'[.,]'));
        if (parts.length == 2 && parts[1].length >= decimalPlaces) {
          return currentAmount;
        }
      } else if (currentAmount.length >= 12) {
        return currentAmount;
      }
    }

    if (currentAmount.isEmpty || currentAmount == '0') {
      return key == '0' ? '0' : key;
    }
    return '$currentAmount$key';
  }

  static String _handleOperator(
    String currentAmount,
    String op, {
    required int decimalPlaces,
  }) {
    if (currentAmount.isEmpty) return currentAmount;

    if (ExpressionEvaluator.hasOperator(currentAmount)) {
      final lastOpIndex = _lastOperatorIndex(currentAmount);
      if (lastOpIndex != null && lastOpIndex == currentAmount.length - 1) {
        return '${currentAmount.substring(0, lastOpIndex)}$op';
      }

      final result = ExpressionEvaluator.evaluate(currentAmount);
      if (result != null) {
        final resultStr = result == result.truncateToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(decimalPlaces);
        return '$resultStr$op';
      }
    }

    return '$currentAmount$op';
  }

  static bool _isOperator(String key) =>
      key == '+' || key == '-' || key == '*' || key == '/';

  static int? _lastOperatorIndex(String amount) {
    for (int i = amount.length - 1; i >= 0; i--) {
      if (_isOperator(amount[i])) return i;
    }
    return null;
  }

  static int _lastNumberStartIndex(String amount) {
    final idx = _lastOperatorIndex(amount);
    return idx != null ? idx + 1 : 0;
  }
}
