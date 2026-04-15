import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({super.key, required this.goal, this.onTap});

  final GoalModel goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shade = findShadeById(goal.colorId);
    final iconData = findIconById(goal.iconId);
    final color = shade?.color ?? colorScheme.primary;

    final icon = iconData?.icon ?? Icons.flag_rounded;
    if (goal.isCompleted) {
      return _buildCompletedCard(context, colorScheme, color, icon);
    }
    return _buildInProgressCard(context, colorScheme, color, icon);
  }

  Widget _buildCompletedCard(
    BuildContext context,
    ColorScheme colorScheme,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizing.defaultPadding),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: AppSizing.spaceBtwElements,
          children: [
            Container(
              height: AppSizing.heightS,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  icon,
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
            Text(
              context.l10n.completed,
              style: AppTextStyles.text14w400(context)
                  .copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressCard(
    BuildContext context,
    ColorScheme colorScheme,
    Color color,
    IconData icon,
  ) {
    final remaining = (goal.targetAmount - goal.progress).clamp(
      0.0,
      double.infinity,
    );
    final targetReached = goal.progress >= goal.targetAmount;

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
                      icon,
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
                goal.hideAmount
                    ? Text(
                        '••••',
                        style: AppTextStyles.text14w400(context)
                            .copyWith(letterSpacing: 2),
                      )
                    : AmountDividerWidget(
                        leftAmount: goal.progress,
                        rightAmount: goal.targetAmount,
                        dividerType: DividerType.slash,
                        styel: AppTextStyles.text14w400(context),
                      ),
                goal.hideAmount
                    ? const SizedBox.shrink()
                    : targetReached
                        ? Text(
                            context.l10n.complete,
                            style: AppTextStyles.text14w400(
                              context,
                            ).copyWith(color: colorScheme.onSurface),
                          )
                        : Text(
                            '${context.l10n.remaining}: ${AmountFormatter.format(remaining)}',
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
