import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
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
                context.l10n.totalProgress,
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
              AmountDividerWidget(
                leftAmount: total.totalProgress,
                rightAmount: total.totalTargetAmount,
                dividerType: DividerType.slash,
                styel: AppTextStyles.text14w400(context),
              ),
              Text(
                '${context.l10n.remaining}: ${AmountFormatter.format(total.remaining)}',
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
                label: context.l10n.goals,
                value: '${total.goalsCount}',
                context: context,
              ),
              _StatItem(
                label: context.l10n.active,
                value: '${total.activeCount}',
                context: context,
              ),
              _StatItem(
                label: context.l10n.completed,
                value: '${total.completedCount}',
                context: context,
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          PrimaryButton(
            text: context.l10n.aiGoalAdviceTotalAsk,
            icon: Icons.auto_awesome_rounded,
            size: PrimaryButtonSize.xSmall,
            rounded: true,
            onPressed: () => AppBottomSheet.showFittedModalBottomSheet(
              context,
              child: const _GoalTotalAiAdviceSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalTotalAiAdviceSheet extends StatelessWidget {
  const _GoalTotalAiAdviceSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(title: context.l10n.aiGoalAdviceTotalTitle),
          const SizedBox(height: AppSizing.spaceBtwElements),
          const GoalAiAdviceSectionWidget(compact: true),
          const SizedBox(height: AppSizing.bottomPadding),
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
