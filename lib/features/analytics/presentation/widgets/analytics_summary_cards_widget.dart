import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsSummaryCardsWidget extends StatelessWidget {
  const AnalyticsSummaryCardsWidget({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.formatter,
    this.budget,
    super.key,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;
  final CurrencyFormatter formatter;
  final BudgetModel? budget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasBudget = budget != null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizing.defaultPadding),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCard('Доход', totalIncome, context),
              const SizedBox(width: AppSizing.spaceBtwItemsExtra),
              _buildCard('Расход', totalExpense, context),
              const SizedBox(width: AppSizing.spaceBtwItemsExtra),
              _buildCard('Баланс', balance, context),
            ],
          ),
        ),
        if (hasBudget) ...[
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _BudgetCard(budget: budget!,
            spent: totalExpense,
            formatter: formatter,
          ),
        ],
          
      ],
    );
  }

  Widget _buildCard(String label, double value, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.text12w400(context)),
          AmountTextWidget(
            amount: value,
            style: AppTextStyles.text20w600(context),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.formatter,
  });

  final BudgetModel budget;
  final double spent;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final exceeded = spent > budget.amount;
    final remainingPercent = budget.amount > 0
        ? ((budget.amount - spent) / budget.amount * 100)
              .clamp(0, 100)
              .toStringAsFixed(0)
        : '0';
    final exceededPercent = budget.amount > 0
        ? ((spent - budget.amount) / budget.amount * 100).toStringAsFixed(0)
        : '0';

    final barSegments = exceeded
        ? [
            BarChartSegment(value: spent, color: colorScheme.error),
            BarChartSegment(value: 0, color: colorScheme.onSecondary),
          ]
        : [
            BarChartSegment(value: spent, color: colorScheme.primary),
            BarChartSegment(
              value: budget.amount - spent,
              color: colorScheme.onSecondary,
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings_outlined,
                size: AppSizing.iconSizeM,
                color: exceeded ? colorScheme.error : colorScheme.primary,
              ),
              const SizedBox(width: AppSizing.spaceBtwItems),
              Text('Бюджет', style: AppTextStyles.sectionTitle(context)),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          SegmentedBar(
            height: 8,
            gap: 3,
            segments: barSegments,
            trackColor: colorScheme.secondary,
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AmountDividerWidget(
                leftAmount: budget.amount,
                rightAmount: spent,
                dividerType: DividerType.slash,
                styel: AppTextStyles.listTileSubtitle(context),
              ),
              Text(
                exceeded
                    ? 'Превышен на $exceededPercent%'
                    : '$remainingPercent% осталось',
                style: AppTextStyles.listTileSubtitle(context).copyWith(
                  color: exceeded ? colorScheme.error : colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}