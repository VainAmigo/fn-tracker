import 'package:fn_tracker/features/transactions/data/models/category_model.dart';

/// Форматирование подписей бюджета и лимитов.
class BudgetDisplayUtils {
  BudgetDisplayUtils._();

  /// Подпись лимита категории: сумма с валютой или процент.
  static String? formatCategoryLimit(
    CategoryModel category, {
    required String currencySymbol,
    required String Function(double amount) formatAmount,
  }) {
    if (!category.hasLimit) return null;
    return switch (category.limitType) {
      CategoryLimitType.fixed =>
        '${formatAmount(category.limitValue!)} $currencySymbol',
      CategoryLimitType.percent => _formatPercent(category.limitValue!),
      CategoryLimitType.none => null,
    };
  }

  static String _formatPercent(double value) {
    final isInt = value == value.roundToDouble();
    return '${isInt ? value.toInt().toString() : value.toStringAsFixed(1)}%';
  }
}
