import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class BudgetDonutStatWidget extends StatelessWidget {
  const BudgetDonutStatWidget({
    super.key,
    required this.budget,
    required this.period,
    required this.totalForPeriod,
    this.history = const [],
    required this.onBudgetTap,
  });

  final BudgetModel budget;
  final DatePickerPeriod period;
  final double totalForPeriod;
  final List<BudgetHistoryEntry> history;
  final VoidCallback onBudgetTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final budgetForPeriod = history.isEmpty
        ? BudgetDisplayUtils.budgetForDisplayPeriod(budget.amount, period)
        : BudgetCalculator.budgetForPeriod(history, period);

    final chartData = BudgetChartData.from(
      budget: budgetForPeriod,
      spent: totalForPeriod,
      colorScheme: colorScheme,
    );

    final exceeded = totalForPeriod > budgetForPeriod;
    final remainingPercent = budgetForPeriod > 0
        ? ((budgetForPeriod - totalForPeriod) / budgetForPeriod * 100)
            .clamp(0, 100)
            .toStringAsFixed(0)
        : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onBudgetTap,
          child: Center(
            child: DonutChart(
              size: 300,
              strokeWidth: 44,
              segments: chartData.segments,
              minSegmentValue: totalForPeriod * 0.02,
              trackColor: colorScheme.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exceeded ? 'Overspent' : 'Spent',
                    style: AppTextStyles.text16w400(context),
                  ),
                  AmountTextWidget(
                    amount: totalForPeriod,
                    style: AppTextStyles.text36w600(context).copyWith(color: chartData.accentColor),
                  ),
                  Text(
                    exceeded ? 'Budget exceeded' : '$remainingPercent% remaining',
                    style: AppTextStyles.tabSubTitle(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        Row(
          spacing: AppSizing.spaceBtwItems,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatColumn(
              label: 'Spent',
              value: totalForPeriod,
            ),
            Container(
              height: AppSizing.heightXS,
              alignment: Alignment.center,
              child: VerticalDivider(
                color: colorScheme.onSecondary,
                width: AppSizing.spaceBtwSections,
                thickness: 1,
              ),
            ),
            _StatColumn(
              label: 'Budget',
              value: budgetForPeriod,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.text16w400(context).copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          AmountTextWidget(
            amount: value,
            style: AppTextStyles.text20w600(context),
          ),
        ],
      ),
    );
  }
}
