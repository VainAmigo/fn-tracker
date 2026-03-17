import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Блок с советами по бюджету: сколько можно потратить в день или рекомендация при превышении.
class BudgetTipsWidget extends StatelessWidget {
  const BudgetTipsWidget({
    super.key,
    required this.budget,
    required this.period,
    required this.totalForPeriod,
    required this.currency,
  });

  final BudgetModel budget;
  final DatePickerPeriod period;
  final double totalForPeriod;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final formatter = CurrencyFormatter(currency);
    final colorScheme = Theme.of(context).colorScheme;
    final result = BudgetDisplayUtils.perDayAmount(
      budget: budget,
      period: period,
      totalSpent: totalForPeriod,
    );

    return switch (result) {
      BudgetPerDayCanSpend(:final amount) => _TipCard(
        icon: Icons.trending_up_rounded,
        iconColor: colorScheme.primary,
        message: 'You can spend ${formatter.format(amount)} per day',
      ),
      BudgetPerDayOverspent(:final amount) => _TipCard(
        icon: Icons.warning_amber_rounded,
        iconColor: colorScheme.error,
        message:
            'Budget exceeded. Try to reduce spending by ${formatter.format(amount)} per day until the end of the period.',
      ),
      BudgetPerDayOverspentPeriodEnded() => _TipCard(
        icon: Icons.warning_amber_rounded,
        iconColor: colorScheme.error,
        message: 'Budget exceeded for this period.',
      ),
    };
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizing.spaceBtwElements,
        vertical: AppSizing.spaceBtwItemsExtra,
      ),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizing.iconSizeM, color: iconColor),
          const SizedBox(width: AppSizing.spaceBtwItems),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.text14w400(
                context,
              ).copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
