import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
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
    required this.currency,
  });

  final BudgetModel budget;
  final DatePickerPeriod period;
  final double totalForPeriod;
  final List<BudgetHistoryEntry> history;
  final List<TransactionModel> transactions;
  final Currency currency;

  static String _periodLabel(DatePickerPeriod period) {
    return switch (period) {
      YearlyPeriod() => 'Yearly budget',
      MonthlyPeriod() => 'Monthly budget',
      WeeklyPeriod() => 'Weekly budget',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = CurrencyFormatter(currency);
    final budgetForPeriod = history.isEmpty
        ? BudgetDisplayUtils.budgetForDisplayPeriod(budget.amount, period)
        : BudgetCalculator.budgetForPeriod(history, period);
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
                    _periodLabel(period),
                    style: AppTextStyles.text12w400(context),
                  ),
                  Text(
                    formatter.format(budgetForPeriod),
                    style: AppTextStyles.text20w600(
                      context,
                    ).copyWith(color: colorScheme.onSurface),
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
