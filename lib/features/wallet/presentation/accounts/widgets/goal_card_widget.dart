import 'package:flutter/material.dart';
import 'package:fn_tracker/components/chart/segmented_bar.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/wallet/wallet.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({
    super.key,
    required this.goal,
    this.onTap,
  });

  final GoalModel goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shade = findShadeById(goal.colorId);
    final iconData = findIconById(goal.iconId);
    final color = shade?.color ?? colorScheme.primary;
    final remaining = (goal.targetAmount - goal.progress).clamp(
      0.0,
      double.infinity,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizing.defaultPadding),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: AppSizing.spaceBtwElements,
              children: [
                Container(
                  height: AppSizing.heightS,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(
                      AppSizing.borderRadius8,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Icon(
                      iconData?.icon ?? Icons.flag_rounded,
                      size: AppSizing.iconSizeS,
                      color: color,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    goal.name,
                    style: AppTextStyles.text20w600(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.spaceBtwElements),
            SegmentedBar(
              segments: [
                BarChartSegment(value: goal.progress, color: color),
                BarChartSegment(
                  value: remaining,
                  color: colorScheme.onSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${goal.progress.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.text14w400(context),
                ),
                Text(
                  'Remaining: \$${remaining.toStringAsFixed(0)}',
                  style: AppTextStyles.text14w400(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
