import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsContentWidget extends StatelessWidget {
  const AnalyticsContentWidget({required this.data, this.period, super.key});

  final AnalyticsPeriodModel data;
  final DatePickerPeriod? period;

  List<WeeklyBarData> _weeklyBarsFromData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return data.weeklySpending
        .map(
          (d) => WeeklyBarData(
            label: Weekday.fromValue(d.weekday).localizedShortName(context),
            segments: d.categorySpending.where((s) => s.amount > 0).map((s) {
              final shade = findShadeById(s.category.colorId);
              final icon = findIconById(s.category.iconId);
              final color = shade?.color ?? colorScheme.outline;
              return BarChartSegment(
                value: s.amount,
                color: color,
                icon: icon?.icon,
              );
            }).toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWeekly = period is WeeklyPeriod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSummaryCardsWidget(
          totalIncome: data.totalIncome,
          totalExpense: data.totalExpense,
          balance: data.balance,
        ),
        const SizedBox(height: AppSizing.spaceBtwSections),
        if (isWeekly) ...[
          TitledSection(
            title: 'По дням недели',
            children: [
              WeeklyStackedBarChart(
                bars: _weeklyBarsFromData(context),
                height: 220,
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
        ],
        if (!isWeekly && data.categorySpending.isNotEmpty) ...[
          AnalyticsSpendingDonutWidget(
            categorySpending: data.categorySpending,
            totalExpense: data.totalExpense,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
        ],
        if (data.categorySpending.isNotEmpty) ...[
          BudgetsSpendingCategoriesListWidget(
            categorySpending: data.categorySpending,
          ),
        ],
        if (data.categorySpending.isEmpty &&
            data.totalIncome == 0 &&
            data.totalExpense == 0)
          const AnalyticsEmptyPlaceholderWidget(),
        const SizedBox(height: AppSizing.bottomPadding),
      ],
    );
  }
}
