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
        Row(
          children: [
            Expanded(
              child: _AnalyticsStatCard(
                label: 'Доход',
                value: formatter.format(totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSizing.spaceBtwItemsExtra),
            Expanded(
              child: _AnalyticsStatCard(
                label: 'Расход',
                value: formatter.format(totalExpense),
                icon: Icons.arrow_upward_rounded,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizing.spaceBtwItemsExtra),
        if (hasBudget) ...[
          _BudgetCard(
            budget: budget!,
            spent: totalExpense,
            formatter: formatter,
          ),
        ],
        const SizedBox(height: AppSizing.spaceBtwItemsExtra),
        _BalanceCard(balance: balance, formatter: formatter),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.formatter});

  final double balance;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: AppSizing.iconSizeM,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSizing.spaceBtwItems),
              Text('Баланс', style: AppTextStyles.sectionTitle(context)),
            ],
          ),
          Text(
            formatter.format(balance),
            style: AppTextStyles.text20w600(context).copyWith(
              color: balance >= 0 ? colorScheme.primary : colorScheme.error,
            ),
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
            BarChartSegment(
              value: spent - budget.amount,
              color: colorScheme.error,
            ),
            BarChartSegment(value: budget.amount, color: colorScheme.onSecondary),
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

class _AnalyticsStatCard extends StatelessWidget {
  const _AnalyticsStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              Icon(icon, size: AppSizing.iconSizeM, color: color),
              const SizedBox(width: AppSizing.spaceBtwItems),
              Text(label, style: AppTextStyles.sectionTitle(context)),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Text(
            value,
            style: AppTextStyles.text20w600(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
