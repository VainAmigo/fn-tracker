import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Верхняя карточка с бюджетом за период, советом и графиком BudgetDailyChart.
class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.budget,
    required this.period,
    required this.totalForPeriod,
    required this.history,
    required this.transactions,
  });

  final BudgetModel budget;
  final DatePickerPeriod period;
  final double totalForPeriod;
  final List<BudgetHistoryEntry> history;
  final List<TransactionModel> transactions;

  static String _periodLabel(DatePickerPeriod period, BuildContext context) {
    return switch (period) {
      YearlyPeriod() => context.l10n.yearlyBudget,
      MonthlyPeriod() => context.l10n.monthlyBudget,
      WeeklyPeriod() => context.l10n.weeklyBudget,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final budgetForPeriod = history.isEmpty
        ? BudgetDisplayUtils.budgetForDisplayPeriod(budget.amount, period)
        : BudgetCalculator.budgetForPeriod(history, period);
    final dailyBudget = BudgetDisplayUtils.dailyBudgetForPeriod(
      budgetForPeriod,
      period,
    );
    final (chartLimits, chartValues) = (
      BudgetCalculator.chartBudgetLimits(history, period),
      BudgetCalculator.chartSpendingValues(transactions, period),
    );

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _periodLabel(period, context),
                    style: AppTextStyles.text12w400(context),
                  ),
                  AmountTextWidget(
                    amount: budgetForPeriod,
                    style: AppTextStyles.text20w600(
                      context,
                    ).copyWith(color: colorScheme.onSurface),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AmountTextWidget(
                        amount: dailyBudget,
                        style: AppTextStyles.text12w400(context).copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        BudgetDisplayUtils.perUnitBudgetLabel(period),
                        style: AppTextStyles.text12w400(context).copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: AppSizing.spaceBtwElements),
              Expanded(
                child: SizedBox(
                  height: AppSizing.heightM,
                  child: chartValues.isEmpty
                      ? const SizedBox.shrink()
                      : BudgetDailyChart(
                          values: chartValues,
                          thresholdValues:
                              chartLimits.length == chartValues.length
                              ? chartLimits
                              : null,
                          height: AppSizing.heightM,
                          barColor: colorScheme.onSurface.withValues(
                            alpha: 0.25,
                          ),
                          exceededColor: colorScheme.error,
                          thresholdLineColor: colorScheme.tertiary,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
