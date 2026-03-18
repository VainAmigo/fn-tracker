import 'package:fn_tracker/core/core.dart';

/// Результат расчёта «сколько можно потратить в день».
sealed class BudgetPerDayResult {
  const BudgetPerDayResult();
}

/// Можно потратить [amount] в день до конца периода.
final class BudgetPerDayCanSpend extends BudgetPerDayResult {
  const BudgetPerDayCanSpend(this.amount);

  final double amount;
}

/// Бюджет превышен. Рекомендуется сократить расходы на [amount] в день.
final class BudgetPerDayOverspent extends BudgetPerDayResult {
  const BudgetPerDayOverspent(this.amount);

  final double amount;
}

/// Бюджет превышен, но период закончился — нет дней для расчёта.
final class BudgetPerDayOverspentPeriodEnded extends BudgetPerDayResult {
  const BudgetPerDayOverspentPeriodEnded();
}

/// Утилиты для расчёта отображаемого бюджета в зависимости от типа и периода.
class BudgetDisplayUtils {
  BudgetDisplayUtils._();

  static const double _weeksPerMonth = 30 / 7;

  /// Бюджет всегда месячный. Приводит к выбранному периоду просмотра.
  static double budgetForDisplayPeriod(
    double monthlyAmount,
    DatePickerPeriod period,
  ) {
    return switch (period) {
      YearlyPeriod() => monthlyAmount * 12,
      MonthlyPeriod() => monthlyAmount,
      WeeklyPeriod() => monthlyAmount / _weeksPerMonth,
    };
  }
}
