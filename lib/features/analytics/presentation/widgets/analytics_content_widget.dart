import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
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
  List<int> _visualOrder = List<int>.from(
    AnalyticsTabOrderStorage.defaultOrder,
  );

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadTabOrder();
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

  Future<void> _loadTabOrder() async {
    final loaded = await AnalyticsTabOrderStorage.load();
    if (!mounted) return;
    final useFirstInOrder = widget.initialTabIndex == 0;
    setState(() {
      _visualOrder = loaded;
      if (useFirstInOrder) {
        _selectedTabIndex = loaded.first;
      }
    });
    if (useFirstInOrder) {
      widget.onTabChanged?.call(loaded.first);
    }
  }

  void _onReorderTabs(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final next = List<int>.from(_visualOrder);
      final item = next.removeAt(oldIndex);
      next.insert(newIndex, item);
      _visualOrder = next;
    });
    unawaited(AnalyticsTabOrderStorage.save(List<int>.from(_visualOrder)));
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
          title: _selectedTabIndex == 3
              ? context.l10n.aiAssistant
              : context.l10n.spendingChart,
          action: _buildTabBar(context),
          children: [
            IndexedStack(
              index: _selectedTabIndex,
              sizing: StackFit.passthrough,
              children: [
                _DonutTabContent(
                  key: const ValueKey('donut'),
                  data: data,
                  period: widget.period,
                ),
                _BarTabContent(
                  key: ValueKey('bar_${widget.period.startDayKey}'),
                  data: data,
                  period: widget.period,
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

    return SizedBox(
      height: AppSizing.heightM,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: _visualOrder.length,
        onReorder: _onReorderTabs,
        itemBuilder: (context, index) {
          final logical = _visualOrder[index];
          return ReorderableDragStartListener(
            key: ValueKey<int>(logical),
            index: index,
            child: IconButton(
              tooltip: _analyticsTabTooltip(logical),
              onPressed: () {
                setState(() => _selectedTabIndex = logical);
                widget.onTabChanged?.call(logical);
              },
              icon: Icon(
                _analyticsTabIcon(logical),
                color: _selectedTabIndex == logical
                    ? activeColor
                    : inactiveColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

IconData _analyticsTabIcon(int logicalIndex) {
  return switch (logicalIndex) {
    0 => Icons.donut_large,
    1 => Icons.bar_chart,
    2 => Icons.calendar_view_week,
    _ => Icons.auto_awesome_outlined,
  };
}

String _analyticsTabTooltip(int logicalIndex) {
  return switch (logicalIndex) {
    0 => 'Donut chart',
    1 => 'Bar chart',
    2 => 'Heatmap',
    _ => 'AI assistant',
  };
}

class _DonutTabContent extends StatelessWidget {
  const _DonutTabContent({
    super.key,
    required this.data,
    required this.period,
  });

  final AnalyticsModel data;
  final DatePickerPeriod period;

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
                onCategoryTap: (spending) => _showCategoryTransactionsSheet(
                  context,
                  spending: spending,
                  period: period,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _BarTabContent extends StatefulWidget {
  const _BarTabContent({super.key, required this.data, required this.period});

  final AnalyticsModel data;
  final DatePickerPeriod period;

  @override
  State<_BarTabContent> createState() => _BarTabContentState();
}

class _BarTabContentState extends State<_BarTabContent> {
  late int _selectedBarIndex;

  @override
  void initState() {
    super.initState();
    _selectedBarIndex = _initialBarIndex(widget.data.periodSegments);
  }

  @override
  void didUpdateWidget(covariant _BarTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.periodSegments != widget.data.periodSegments) {
      setState(() {
        _selectedBarIndex = _clampBarIndex(
          _initialBarIndex(widget.data.periodSegments),
          widget.data.periodSegments.length,
        );
      });
    }
  }

  int _initialBarIndex(List<PeriodSegmentItem> segments) {
    final idx = segments.indexWhere((s) => s.isInitialVisible);
    return idx >= 0 ? idx : 0;
  }

  int _clampBarIndex(int index, int length) {
    if (length <= 0) return 0;
    return index.clamp(0, length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.data.periodSegments;
    final bars = segments
        .map(
          (s) => PeriodSegmentData.fromCategorySpendingList(
            label: s.label,
            categorySpending: s.categorySpending,
            isInitialVisible: s.isInitialVisible,
          ),
        )
        .toList();

    final idx = _clampBarIndex(_selectedBarIndex, segments.length);
    final selectedSegment = segments.isEmpty ? null : segments[idx];
    final listAnimationKey = selectedSegment == null
        ? const ValueKey('bar_list_empty')
        : ValueKey(
            Object.hash(
              idx,
              selectedSegment.total,
              Object.hashAll(
                selectedSegment.categorySpending.map(
                  (s) => Object.hash(s.category.categoryId, s.amount),
                ),
              ),
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
        if (segments.isNotEmpty)
          PeriodSegmentChart(
            bars: bars,
            selectedBarIndex: idx,
            onBarSelected: (i) => setState(() => _selectedBarIndex = i),
          ),
        if (selectedSegment != null &&
            selectedSegment.categorySpending.any((c) => c.amount > 0)) ...[
          const SizedBox(height: AppSizing.spaceBtwSections),
          TweenAnimationBuilder<double>(
            key: listAnimationKey,
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return SpendingCategoriesListWidget(
                categorySpending: selectedSegment.categorySpending,
                progress: progress,
                onCategoryTap: (spending) => _showCategoryTransactionsSheet(
                  context,
                  spending: spending,
                  period: _barSegmentPeriod(widget.period, idx),
                ),
              );
            },
          ),
        ],
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
              onCategoryTap: (spending) => _showCategoryTransactionsSheet(
                context,
                spending: spending,
                period: _heatmapDayPeriod(selectedDay.date),
              ),
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

/// Период одного календарного дня (для списка категорий в heatmap).
WeeklyPeriod _heatmapDayPeriod(DateTime day) {
  final start = DateTime(day.year, day.month, day.day);
  final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
  return WeeklyPeriod(start: start, end: end);
}

/// Период, соответствующий столбцу bar-графика (день месяца / месяц года / день недели).
DatePickerPeriod _barSegmentPeriod(
  DatePickerPeriod analyticsPeriod,
  int segmentIndex,
) {
  return switch (analyticsPeriod) {
    YearlyPeriod(:final year) => MonthlyPeriod(
        year: year,
        month: Month.fromValue(segmentIndex + 1),
      ),
    MonthlyPeriod(:final year, :final month) => _heatmapDayPeriod(
        DateTime(year, month.value, segmentIndex + 1),
      ),
    WeeklyPeriod(:final start, :final end) => _heatmapDayPeriod(
        _dateForWeekdayInWeek(start, end, segmentIndex + 1),
      ),
  };
}

DateTime _dateForWeekdayInWeek(
  DateTime weekStart,
  DateTime weekEnd,
  int weekday,
) {
  var cursor = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final last = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
  while (!cursor.isAfter(last)) {
    if (cursor.weekday == weekday) return cursor;
    cursor = cursor.add(const Duration(days: 1));
  }
  return DateTime(weekStart.year, weekStart.month, weekStart.day);
}

void _showCategoryTransactionsSheet(
  BuildContext context, {
  required CategorySpending spending,
  required DatePickerPeriod period,
}) {
  AppBottomSheet.showFittedModalBottomSheet(
    context,
    child: TransactionsListByIdView(
      idType: TransactionIdType.category,
      id: spending.category.categoryId,
      analyticsPeriod: period,
      listTitle: spending.category.name,
    ),
  );
}
