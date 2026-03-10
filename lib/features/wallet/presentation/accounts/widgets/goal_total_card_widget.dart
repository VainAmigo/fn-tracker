import 'package:flutter/material.dart';
import 'package:fn_tracker/components/chart/segmented_bar.dart';
import 'package:fn_tracker/features/wallet/wallet.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalTotalCardWidget extends StatelessWidget {
  const GoalTotalCardWidget({super.key, required this.total});

  final TotalGoalModel total;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total progress',
                style: AppTextStyles.text14w400(
                  context,
                  color: colorScheme.onSecondary,
                ),
              ),
              Text(
                '${total.percent.toStringAsFixed(0)}%',
                style: AppTextStyles.text20w600(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          SegmentedBar(
            segments: [
              BarChartSegment(
                value: total.totalProgress,
                color: colorScheme.primary,
              ),
              BarChartSegment(
                value: total.remaining,
                color: colorScheme.onSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${total.totalProgress.toStringAsFixed(0)} / \$${total.totalTargetAmount.toStringAsFixed(0)}',
                style: AppTextStyles.text14w400(context),
              ),
              Text(
                'Remaining: \$${total.remaining.toStringAsFixed(0)}',
                style: AppTextStyles.text14w400(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Divider(color: colorScheme.onSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Goals',
                value: '${total.goalsCount}',
                context: context,
              ),
              _StatItem(
                label: 'Active',
                value: '${total.activeCount}',
                context: context,
              ),
              _StatItem(
                label: 'Completed',
                value: '${total.completedCount}',
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.context,
  });

  final String label;
  final String value;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value, style: AppTextStyles.text20w600(context)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.text14w400(
            context,
            color: colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
