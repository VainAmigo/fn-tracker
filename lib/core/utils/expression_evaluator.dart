/// Безопасный вычислитель математических выражений.
///
/// Поддерживает только числа и операторы + - * /.
/// Не использует eval() — парсинг вручную.
class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// Вычисляет выражение вида "65*44", "10+20", "100-30", "50/2".
  /// Возвращает null при невалидном выражении или делении на ноль.
  static double? evaluate(String expr) {
    final trimmed = expr.trim();
    if (trimmed.isEmpty) return null;

    // Ищем последний оператор с учётом приоритета: + - ниже чем * /
    // Сначала * и /
    final mulDivIndex = _findLastOperator(trimmed, ['*', '/']);
    if (mulDivIndex != null) {
      final left = evaluate(trimmed.substring(0, mulDivIndex));
      final right = evaluate(trimmed.substring(mulDivIndex + 1));
      if (left == null || right == null) return null;
      final op = trimmed[mulDivIndex];
      if (op == '*') return left * right;
      if (op == '/' && right == 0) return null;
      return op == '/' ? left / right : left * right;
    }

    // Затем + и - (минус не в начале)
    final addSubIndex = _findLastOperator(trimmed, ['+', '-']);
    if (addSubIndex != null && addSubIndex > 0) {
      final left = evaluate(trimmed.substring(0, addSubIndex));
      final right = evaluate(trimmed.substring(addSubIndex + 1));
      if (left == null || right == null) return null;
      return trimmed[addSubIndex] == '+' ? left + right : left - right;
    }

    return double.tryParse(_normalizeNumber(trimmed));
  }

  static int? _findLastOperator(String s, List<String> ops) {
    int? lastIndex;
    for (int i = s.length - 1; i >= 0; i--) {
      final c = s[i];
      if (ops.contains(c)) {
        // Не считаем минус в начале числа
        if (c == '-' && i == 0) continue;
        lastIndex = i;
        break;
      }
    }
    return lastIndex;
  }

  static String _normalizeNumber(String s) {
    return s.replaceAll(',', '.');
  }

  /// Проверяет, содержит ли строка математический оператор.
  static bool hasOperator(String expr) {
    return RegExp(r'[+\-*/]').hasMatch(expr);
  }
}
