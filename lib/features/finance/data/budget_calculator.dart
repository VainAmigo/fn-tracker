import 'package:fn_tracker/features/transactions/data/models/category_model.dart';
import 'package:fn_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:fn_tracker/features/finance/data/models/budget_model.dart';

/// Расчёт месячного бюджета и лимитов категорий.
class BudgetCalculator {
  BudgetCalculator._();

  /// Сумма бюджета на месяц [monthKey] (`YYYY-MM`):
  /// последняя запись с `effectiveMonthKey <= monthKey`.
  static double? amountForMonth(
    List<BudgetHistoryEntry> history,
    String monthKey,
  ) {
    if (history.isEmpty) return null;
    final applicable = history
        .where((e) => e.effectiveMonthKey.compareTo(monthKey) <= 0)
        .toList()
      ..sort((a, b) => b.effectiveMonthKey.compareTo(a.effectiveMonthKey));
    if (applicable.isEmpty) return null;
    return applicable.first.amount;
  }

  /// Абсолютный лимит категории в валюте.
  static double absoluteLimit(CategoryModel category, double budgetAmount) {
    if (!category.hasLimit) return 0;
    return switch (category.limitType) {
      CategoryLimitType.fixed => category.limitValue!,
      CategoryLimitType.percent => budgetAmount * (category.limitValue! / 100),
      CategoryLimitType.none => 0,
    };
  }

  /// Сумма всех выделенных лимитов категорий.
  static double allocatedTotal(
    Iterable<CategoryModel> categories,
    double budgetAmount,
  ) {
    var total = 0.0;
    for (final c in categories) {
      total += absoluteLimit(c, budgetAmount);
    }
    return total;
  }

  /// Остаток бюджета после вычета лимитов.
  static double remainingAfterLimits(
    double budgetAmount,
    Iterable<CategoryModel> categories,
  ) {
    return budgetAmount - allocatedTotal(categories, budgetAmount);
  }

  /// Остаток без учёта лимита [excludeCategoryId].
  static double remainingExcluding(
    double budgetAmount,
    Iterable<CategoryModel> categories,
    String? excludeCategoryId,
  ) {
    final others = categories.where((c) => c.categoryId != excludeCategoryId);
    return remainingAfterLimits(budgetAmount, others);
  }

  /// Новый абсолютный лимит превысит остаток (без этой категории).
  static bool wouldExceedRemaining({
    required double budgetAmount,
    required Iterable<CategoryModel> categories,
    required String? categoryId,
    required CategoryLimitType limitType,
    required double limitValue,
  }) {
    if (limitType == CategoryLimitType.none || limitValue <= 0) return false;
    final remaining = remainingExcluding(budgetAmount, categories, categoryId);
    final draft = CategoryModel(
      categoryId: categoryId ?? '',
      colorId: '',
      iconId: '',
      name: '',
      limitType: limitType,
      limitValue: limitValue,
    );
    return absoluteLimit(draft, budgetAmount) > remaining + 1e-9;
  }

  /// Сумма только фикс-лимитов (для проверки при смене бюджета).
  static double fixedLimitsTotal(Iterable<CategoryModel> categories) {
    var total = 0.0;
    for (final c in categories) {
      if (c.limitType == CategoryLimitType.fixed &&
          c.limitValue != null &&
          c.limitValue! > 0) {
        total += c.limitValue!;
      }
    }
    return total;
  }

  /// Дневные траты для месячного графика.
  static List<double> monthlyChartSpendingValues({
    required int year,
    required int month,
    required List<TransactionModel> transactions,
  }) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    final barCount = end.difference(start).inDays + 1;
    final byDay = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        byDay[t.dayKey] = (byDay[t.dayKey] ?? 0) + t.amount;
      }
    }
    final result = <double>[];
    for (var i = 0; i < barCount; i++) {
      final d = start.add(Duration(days: i));
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      result.add(byDay['${d.year}-$m-$day'] ?? 0);
    }
    return result;
  }

  /// Дневной лимит бюджета (равномерно на дни месяца).
  static List<double> monthlyChartBudgetLimits({
    required int year,
    required int month,
    required double budgetAmount,
  }) {
    final days = DateTime(year, month + 1, 0).day;
    final daily = days > 0 ? budgetAmount / days : 0.0;
    return List.filled(days, daily);
  }
}
