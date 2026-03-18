import 'package:fn_tracker/core/utils/expression_evaluator.dart';

/// Утилиты для парсинга и форматирования суммы в формах ввода.
class AmountFormUtils {
  AmountFormUtils._();

  static String formatAmountForInput(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.truncate().toString();
    }
    return amount.toString();
  }

  /// Парсит сумму: поддерживает числа и выражения (100+50, 10*2).
  /// Возвращает null при пустой или невалидной строке.
  static double? parseAmount(String text, {bool allowExpressions = true}) {
    var t = text.trim();
    if (t.isEmpty) return null;
    const operators = ['+', '-', '*', '/'];
    while (t.length > 1 && operators.contains(t[t.length - 1])) {
      t = t.substring(0, t.length - 1).trim();
    }
    if (t.isEmpty) return null;
    if (allowExpressions && ExpressionEvaluator.hasOperator(t)) {
      final evaluated = ExpressionEvaluator.evaluate(t);
      if (evaluated != null && evaluated > 0) return evaluated;
    }
    final parsed = double.tryParse(t.replaceAll(',', '.'));
    return parsed != null && parsed > 0 ? parsed : null;
  }
}
