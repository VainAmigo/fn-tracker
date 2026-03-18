import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsSummaryCardsWidget extends StatelessWidget {
  const AnalyticsSummaryCardsWidget({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCard(context, 'Доход', totalIncome),
          const SizedBox(width: AppSizing.spaceBtwItemsExtra),
          _buildCard(context, 'Расход', totalExpense),
          const SizedBox(width: AppSizing.spaceBtwItemsExtra),
          _buildCard(context, 'Баланс', balance),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String label, double value) {
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
