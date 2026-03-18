import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsSummaryCardsWidget extends StatelessWidget {
  const AnalyticsSummaryCardsWidget({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    super.key,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
