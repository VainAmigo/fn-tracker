import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

import 'analytics_empty_placeholder_widget.dart';
import 'analytics_spending_donut_widget.dart';
import 'analytics_summary_cards_widget.dart';
import 'analytics_trend_chart_widget.dart';

class AnalyticsContentWidget extends StatelessWidget {
  const AnalyticsContentWidget({required this.data, super.key});

  final AnalyticsPeriodModel data;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    final formatter = CurrencyFormatter(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSummaryCardsWidget(
          totalIncome: data.totalIncome,
          totalExpense: data.totalExpense,
          balance: data.balance,
          formatter: formatter,
        ),
        const SizedBox(height: AppSizing.spaceBtwSections),
        if (data.monthlyTrend.length > 1) ...[
          AnalyticsTrendChartWidget(
            monthlyTrend: data.monthlyTrend,
            formatter: formatter,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
        ],
        if (data.categorySpending.isNotEmpty) ...[
          AnalyticsSpendingDonutWidget(
            categorySpending: data.categorySpending,
            totalExpense: data.totalExpense,
            formatter: formatter,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          BudgetsSpendingCategoriesListWidget(
            categorySpending: data.categorySpending,
            currency: currency,
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
