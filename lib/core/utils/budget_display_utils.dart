import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

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

  /// Возвращает бюджет, приведённый к выбранному периоду просмотра.
  static double budgetForDisplayPeriod(
    BudgetModel budget,
    DatePickerPeriod period,
  ) {
    final amount = budget.amount;

    return switch ((budget.type, period)) {
      (BudgetType.yearly, YearlyPeriod()) => amount,
      (BudgetType.yearly, MonthlyPeriod()) => amount / 12,
      (BudgetType.yearly, WeeklyPeriod()) => amount / 52,
      (BudgetType.monthly, YearlyPeriod()) => amount * 12,
      (BudgetType.monthly, MonthlyPeriod()) => amount,
      (BudgetType.monthly, WeeklyPeriod()) => amount / _weeksPerMonth,
      (BudgetType.weekly, YearlyPeriod()) => amount * 52,
      (BudgetType.weekly, MonthlyPeriod()) => amount * _weeksPerMonth,
      (BudgetType.weekly, WeeklyPeriod()) => amount,
    };
  }

  /// Количество дней в периоде.
  static int daysInPeriod(DatePickerPeriod period) {
    final start = period.startDate;
    final end = period.endDate;
    return end.difference(start).inDays + 1;
  }

  /// Количество оставшихся дней в периоде (включая сегодня).
  /// Возвращает 0 если период уже закончился, или полное количество дней если период ещё не начался.
  static int daysRemaining(DatePickerPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      period.startDate.year,
      period.startDate.month,
      period.startDate.day,
    );
    final end = DateTime(
      period.endDate.year,
      period.endDate.month,
      period.endDate.day,
    );

    if (today.isBefore(start)) {
      return daysInPeriod(period);
    }
    if (today.isAfter(end)) {
      return 0;
    }
    return end.difference(today).inDays + 1;
  }

  /// Считает «сколько можно потратить в день» или «сократить на X в день».
  static BudgetPerDayResult perDayAmount({
    required BudgetModel budget,
    required DatePickerPeriod period,
    required double totalSpent,
  }) {
    final budgetForPeriod = budgetForDisplayPeriod(budget, period);
    final daysRem = daysRemaining(period);

    if (totalSpent <= budgetForPeriod) {
      if (daysRem <= 0) return const BudgetPerDayCanSpend(0);
      final remaining = budgetForPeriod - totalSpent;
      return BudgetPerDayCanSpend(remaining / daysRem);
    }

    // Exceeded
    if (daysRem <= 0) return const BudgetPerDayOverspentPeriodEnded();
    final overspent = totalSpent - budgetForPeriod;
    return BudgetPerDayOverspent(overspent / daysRem);
  }
}
