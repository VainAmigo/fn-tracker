import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsSpendingDonutWidget extends StatelessWidget {
  const AnalyticsSpendingDonutWidget({
    required this.categorySpending,
    required this.totalExpense,
    required this.formatter,
    super.key,
  });

  final List<CategorySpending> categorySpending;
  final double totalExpense;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (categorySpending.isEmpty || totalExpense <= 0) {
      return const SizedBox.shrink();
    }

    final segments = categorySpending
        .map((s) {
          final shade = findShadeById(s.category.colorId);
          final color = shade?.color ?? colorScheme.outline;
          return DonutChartSegment(value: s.amount, color: color);
        })
        .where((s) => s.value > 0)
        .toList();

    if (segments.isEmpty) return const SizedBox.shrink();

    return TitledSection(
      title: 'Категории',
      children: [
        Center(
          child: DonutChart(
            size: 220,
            strokeWidth: 22,
            segments: segments,
            trackColor: colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Всего', style: AppTextStyles.text16w400(context)),
                Text(
                  formatter.format(totalExpense),
                  style: AppTextStyles.text20w600(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
