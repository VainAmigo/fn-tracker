import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsAiChatCubit>().bindAnalyticsContext(
        widget.data,
        widget.period,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AnalyticsContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _selectedTabIndex = widget.initialTabIndex;
    }
    final newKey = AnalyticsAiContextBuilder.periodContextKey(widget.period);
    final oldKey = AnalyticsAiContextBuilder.periodContextKey(oldWidget.period);
    if (newKey != oldKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AnalyticsAiChatCubit>().bindAnalyticsContext(
          widget.data,
          widget.period,
        );
      });
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
        TitledSection(
          title: _selectedTabIndex == 3 ? 'AI assistant' : 'Spending chart',
          action: _buildTabBar(context),
          children: [
            IndexedStack(
              index: _selectedTabIndex,
              sizing: StackFit.passthrough,
              children: [
                _DonutTabContent(key: const ValueKey('donut'), data: data),
                _BarTabContent(
                  key: ValueKey('bar_${widget.period.startDayKey}'),
                  data: data,
                ),
                _HeatmapTabContent(
                  key: ValueKey('heatmap_${widget.period.startDayKey}'),
                  data: data,
                  period: widget.period,
                ),
                const AnalyticsAiChatTabWidget(),
              ],
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
        IconButton(
          onPressed: () {
            setState(() => _selectedTabIndex = 2);
            widget.onTabChanged?.call(2);
          },
          icon: Icon(
            Icons.calendar_view_week,
            color: _selectedTabIndex == 2 ? activeColor : inactiveColor,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => _selectedTabIndex = 3);
            widget.onTabChanged?.call(3);
          },
          icon: Icon(
            Icons.auto_awesome_outlined,
            color: _selectedTabIndex == 3 ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

class _DonutTabContent extends StatelessWidget {
  const _DonutTabContent({super.key, required this.data});

  final AnalyticsModel data;

  @override
  Widget build(BuildContext context) {
    final listAnimationKey = ValueKey(
      Object.hashAll(
        data.categorySpending.map(
          (s) => Object.hash(s.category.categoryId, s.amount),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.categorySpending.isNotEmpty) ...[
          AnalyticsSummaryCardsWidget(
            totalIncome: data.totalIncome,
            totalExpense: data.totalExpense,
            balance: data.balance,
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          AnalyticsSpendingDonutWidget(
            categorySpending: data.categorySpending,
            totalExpense: data.totalExpense,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          TweenAnimationBuilder<double>(
            key: listAnimationKey,
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return SpendingCategoriesListWidget(
                categorySpending: data.categorySpending,
                progress: progress,
              );
            },
          ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSummaryCardsWidget(
          totalIncome: data.totalIncome,
          totalExpense: data.totalExpense,
          balance: data.balance,
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        PeriodSegmentChart(bars: bars),
      ],
    );
  }
}

class _HeatmapTabContent extends StatefulWidget {
  const _HeatmapTabContent({
    super.key,
    required this.data,
    required this.period,
  });

  final AnalyticsModel data;
  final DatePickerPeriod period;

  @override
  State<_HeatmapTabContent> createState() => _HeatmapTabContentState();
}

class _HeatmapTabContentState extends State<_HeatmapTabContent> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _resolveDefaultDate(widget.data.daySpending);
  }

  @override
  void didUpdateWidget(covariant _HeatmapTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period.startDayKey != widget.period.startDayKey ||
        oldWidget.data.daySpending != widget.data.daySpending) {
      _selectedDate = _resolveDefaultDate(widget.data.daySpending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daySpending = widget.data.daySpending;
    if (daySpending.isEmpty) return const SizedBox.shrink();

    final selectedDay = daySpending.firstWhere(
      (item) => _isSameDay(item.date, _selectedDate),
      orElse: () => daySpending.last,
    );
    final listAnimationKey = ValueKey(
      Object.hash(
        selectedDay.date.day,
        selectedDay.date.month,
        selectedDay.date.year,
        selectedDay.total,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSummaryCardsWidget(
          totalIncome: widget.data.totalIncome,
          totalExpense: widget.data.totalExpense,
          balance: widget.data.balance,
        ),
        const SizedBox(height: AppSizing.spaceBtwElements),
        SpendingHeatmapCalendarWidget(
          days: daySpending,
          period: widget.period,
          selectedDate: selectedDay.date,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        Row(
          children: [
            Text(
              selectedDay.date.formatDayMonthShort(context),
              style: AppTextStyles.text12w400(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSecondary),
            ),
            const Spacer(),
            AmountTextWidget(
              amount: selectedDay.total,
              maxLines: 1,
              style: AppTextStyles.text14w400(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizing.spaceBtwSections),
        TweenAnimationBuilder<double>(
          key: listAnimationKey,
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) {
            return SpendingCategoriesListWidget(
              categorySpending: selectedDay.categorySpending,
              progress: progress,
            );
          },
        ),
      ],
    );
  }

  DateTime _resolveDefaultDate(List<AnalyticsDaySpending> days) {
    if (days.isEmpty) return DateTime.now();
    final now = DateTime.now();
    for (final item in days) {
      if (_isSameDay(item.date, now)) return item.date;
    }
    return days.last.date;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
