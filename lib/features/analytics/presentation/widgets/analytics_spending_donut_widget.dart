import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsSpendingDonutWidget extends StatelessWidget {
  const AnalyticsSpendingDonutWidget({
    required this.categorySpending,
    required this.totalExpense,
    super.key,
  });

  final List<CategorySpending> categorySpending;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (categorySpending.isEmpty || totalExpense <= 0) {
      return const SizedBox.shrink();
    }

    final segments = categorySpending
        .map((s) {
          final shade = findShadeById(s.category.colorId);
          final icon = findIconById(s.category.iconId);
          final color = shade?.color ?? colorScheme.outline;
          return DonutChartSegment(
            value: s.amount,
            color: color,
            icon: icon != null
                ? Icon(icon.icon, size: 22, color: colorScheme.onSurface)
                : null,
          );
        })
        .where((s) => s.value > 0)
        .toList();

    if (segments.isEmpty) return const SizedBox.shrink();

    return Center(
      child: DonutChart(
        size: 300,
        strokeWidth: 44,
        segments: segments,
        iconSize: 32,
        minSegmentValue: totalExpense * 0.02,
        trackColor: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.spent,
              style: AppTextStyles.text12w400(
                context,
              ).copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            AmountTextWidget(
              amount: totalExpense,
              style: AppTextStyles.text36w600(context),
            ),
          ],
        ),
      ),
    );
  }
}
