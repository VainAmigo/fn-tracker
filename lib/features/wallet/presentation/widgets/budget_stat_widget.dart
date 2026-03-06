import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class BudgetStatWidget extends StatelessWidget {
  const BudgetStatWidget({
    super.key,
    required this.budget,
    required this.totalForPeriod,
    required this.currency,
    required this.onEditBudgetPressed,
  });

  final BudgetModel budget;
  final double totalForPeriod;
  final Currency currency;
  final VoidCallback onEditBudgetPressed;

  @override
  Widget build(BuildContext context) {
    final formatter = CurrencyFormatter(currency);
    final remaining = budget.amount - totalForPeriod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatRow(
          label: 'Budget',
          value: formatter.format(budget.amount),
          style: AppTextStyles.text16w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        _StatRow(
          label: 'Spent',
          value: formatter.format(totalForPeriod),
          style: AppTextStyles.text16w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        _StatRow(
          label: 'Remaining',
          value: formatter.format(remaining),
          style: AppTextStyles.text16w400(context).copyWith(
            color: remaining >= 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizing.borderRadius4),
          child: LinearProgressIndicator(
            value: budget.amount > 0
                ? (totalForPeriod / budget.amount).clamp(0.0, 1.0)
                : 0,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            color: totalForPeriod > budget.amount
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        PrimaryButton(
          text: 'Edit budget',
          size: PrimaryButtonSize.xSmall,
          rounded: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          onPressed: onEditBudgetPressed,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.text16w400(context)),
        Text(value, style: style),
      ],
    );
  }
}
