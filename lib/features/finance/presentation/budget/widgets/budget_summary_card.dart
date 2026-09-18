import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Верхняя карточка: месячный бюджет, остаток после лимитов, график трат.
class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.stats,
    required this.year,
    required this.month,
    required this.onTap,
  });

  final BudgetStatModel stats;
  final int year;
  final int month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final budgetAmount = stats.budgetAmount;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final dailyBudget = daysInMonth > 0 ? budgetAmount / daysInMonth : 0.0;
    final chartValues = BudgetCalculator.monthlyChartSpendingValues(
      year: year,
      month: month,
      transactions: stats.transactions,
    );
    final chartLimits = BudgetCalculator.monthlyChartBudgetLimits(
      year: year,
      month: month,
      budgetAmount: budgetAmount,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizing.defaultPadding),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.monthlyBudget,
                      style: AppTextStyles.text12w400(context),
                    ),
                    AmountTextWidget(
                      amount: budgetAmount,
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
                          ' / day',
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
            const SizedBox(height: AppSizing.spaceBtwItems),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: context.l10n.allocatedLimits,
                    amount: stats.allocatedLimits,
                  ),
                ),
                const SizedBox(width: AppSizing.spaceBtwItems),
                Expanded(
                  child: _StatChip(
                    label: context.l10n.remainingBudget,
                    amount: stats.remainingAfterLimits,
                    emphasize: stats.remainingAfterLimits < 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.amount,
    this.emphasize = false,
  });

  final String label;
  final double amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizing.spaceBtwItems),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.text12w400(
              context,
            ).copyWith(color: colorScheme.onSecondary),
          ),
          AmountTextWidget(
            amount: amount,
            style: AppTextStyles.text14w400(context).copyWith(
              color: emphasize ? colorScheme.error : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
