import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsSummaryCardsWidget extends StatelessWidget {
  const AnalyticsSummaryCardsWidget({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.formatter,
    super.key,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            const SizedBox(width: AppSizing.spaceBtwItems),
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
        const SizedBox(height: AppSizing.spaceBtwItems),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizing.defaultPadding),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Баланс', style: AppTextStyles.sectionTitle(context)),
              Text(
                formatter.format(balance),
                style: AppTextStyles.text20w600(context).copyWith(
                  color: balance >= 0 ? colorScheme.primary : colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
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
