import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AnalyticsContentWidget extends StatefulWidget {
  const AnalyticsContentWidget({
    required this.data,
    required this.period,
    this.initialTabIndex = 0,
    this.onTabChanged,
    super.key,
  });

  final AnalyticsModel data;
  final DatePickerPeriod period;
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;

  @override
  State<AnalyticsContentWidget> createState() => _AnalyticsContentWidgetState();
}

class _AnalyticsContentWidgetState extends State<AnalyticsContentWidget> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(covariant AnalyticsContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _selectedTabIndex = widget.initialTabIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    if (data.categorySpending.isEmpty &&
        data.totalIncome == 0 &&
        data.totalExpense == 0) {
      return const AnalyticsEmptyPlaceholderWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSummaryCardsWidget(
          totalIncome: data.totalIncome,
          totalExpense: data.totalExpense,
          balance: data.balance,
        ),
        const SizedBox(height: AppSizing.spaceBtwSections),
        TitledSection(
          title: 'Spending chart',
          action: _buildTabBar(context),
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedTabIndex == 0
                  ? _DonutTabContent(
                      key: const ValueKey('donut'),
                      data: data,
                    )
                  : _BarTabContent(
                      key: ValueKey('bar_${widget.period.startDayKey}'),
                      data: data,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.tertiary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.5);

    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() => _selectedTabIndex = 0);
            widget.onTabChanged?.call(0);
          },
          icon: Icon(
            Icons.donut_large,
            color: _selectedTabIndex == 0 ? activeColor : inactiveColor,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => _selectedTabIndex = 1);
            widget.onTabChanged?.call(1);
          },
          icon: Icon(
            Icons.bar_chart,
            color: _selectedTabIndex == 1 ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

class _DonutTabContent extends StatelessWidget {
  const _DonutTabContent({
    super.key,
    required this.data,
  });

  final AnalyticsModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.categorySpending.isNotEmpty) ...[
          AnalyticsSpendingDonutWidget(
            categorySpending: data.categorySpending,
            totalExpense: data.totalExpense,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          SpendingCategoriesListWidget(categorySpending: data.categorySpending),
        ],
      ],
    );
  }
}

class _BarTabContent extends StatelessWidget {
  const _BarTabContent({super.key, required this.data});

  final AnalyticsModel data;

  @override
  Widget build(BuildContext context) {
    final bars = data.periodSegments
        .map(
          (s) => PeriodSegmentData.fromCategorySpendingList(
            label: s.label,
            categorySpending: s.categorySpending,
            isInitialVisible: s.isInitialVisible,
          ),
        )
        .toList();

    return PeriodSegmentChart(bars: bars);
  }
}
