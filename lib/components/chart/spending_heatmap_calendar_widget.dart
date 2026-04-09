import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

/// GitHub-like heatmap календарь расходов.
class SpendingHeatmapCalendarWidget extends StatefulWidget {
  const SpendingHeatmapCalendarWidget({
    super.key,
    required this.days,
    required this.period,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final List<AnalyticsDaySpending> days;
  final DatePickerPeriod period;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<SpendingHeatmapCalendarWidget> createState() =>
      _SpendingHeatmapCalendarWidgetState();
}

class _SpendingHeatmapCalendarWidgetState
    extends State<SpendingHeatmapCalendarWidget> {
  static const double _yearlyCellSize = 30;
  static const double _cellGap = 4;
  final ScrollController _yearlyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scheduleYearlyScrollToSelected();
  }

  @override
  void didUpdateWidget(covariant SpendingHeatmapCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.period != widget.period ||
        oldWidget.days != widget.days) {
      _scheduleYearlyScrollToSelected();
    }
  }

  @override
  void dispose() {
    _yearlyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) return const SizedBox.shrink();
    return switch (widget.period) {
      YearlyPeriod() => _buildYearly(context),
      MonthlyPeriod() => _buildMonthly(context),
      WeeklyPeriod() => _buildWeekly(context),
    };
  }

  Widget _buildWeekly(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - (_cellGap * 6)) / 7;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekdayHeaderRow(context, cellSize: cellSize),
            const SizedBox(height: AppSizing.spaceBtwItemsExtra),
            Row(
              children: widget.days.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.days.length - 1 ? 0 : _cellGap,
                  ),
                  child: _buildCell(
                    context,
                    item: item,
                    size: cellSize,
                    showDayNumber: true,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthly(BuildContext context) {
    final firstDay = widget.days.first.date;
    final startWeekdayOffset = firstDay.weekday - 1;
    final totalCells = startWeekdayOffset + widget.days.length;
    final rows = (totalCells / 7).ceil();
    final byIndex = <int, AnalyticsDaySpending>{};
    for (int i = startWeekdayOffset; i < totalCells; i++) {
      byIndex[i] = widget.days[i - startWeekdayOffset];
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - (_cellGap * 6)) / 7;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekdayHeaderRow(context, cellSize: cellSize),
            const SizedBox(height: AppSizing.spaceBtwItemsExtra),
            for (int row = 0; row < rows; row++) ...[
              if (row > 0) const SizedBox(height: _cellGap),
              Row(
                children: List.generate(7, (col) {
                  final absoluteIndex = row * 7 + col;
                  final dayItem = byIndex[absoluteIndex];
                  return Padding(
                    padding: EdgeInsets.only(right: col == 6 ? 0 : _cellGap),
                    child: dayItem == null
                        ? _emptyCell(size: cellSize)
                        : _buildCell(
                            context,
                            item: dayItem,
                            size: cellSize,
                            showDayNumber: true,
                          ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildYearly(BuildContext context) {
    final yearStart = DateTime(widget.days.first.date.year, 1, 1);
    final startWeekdayOffset = yearStart.weekday - 1;
    final totalCells = startWeekdayOffset + widget.days.length;
    final totalWeeks = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          controller: _yearlyScrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(totalWeeks, (weekIndex) {
                  final weekStartDayIndex = (weekIndex * 7) - startWeekdayOffset;
                  final monthLabel = _monthLabelForWeekChunk(
                    context,
                    weekStartDayIndex,
                  );
                  return SizedBox(
                    width: _yearlyCellSize + (weekIndex == totalWeeks - 1 ? 0 : _cellGap),
                    child: Text(
                      monthLabel,
                      style: AppTextStyles.text12w400(context).copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(totalWeeks, (weekIndex) {
                  return Padding(
                    padding: EdgeInsets.only(right: weekIndex == totalWeeks - 1 ? 0 : _cellGap),
                    child: Column(
                      children: List.generate(7, (weekdayIndex) {
                        final absoluteCellIndex = weekIndex * 7 + weekdayIndex;
                        final dayIndex = absoluteCellIndex - startWeekdayOffset;
                        final cell = (dayIndex < 0 || dayIndex >= widget.days.length)
                            ? _emptyCell(size: _yearlyCellSize)
                            : _buildCell(
                                context,
                                item: widget.days[dayIndex],
                                size: _yearlyCellSize,
                                showDayNumber: false,
                              );
                        return Padding(
                          padding: EdgeInsets.only(bottom: weekdayIndex == 6 ? 0 : _cellGap),
                          child: cell,
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required AnalyticsDaySpending item,
    required double size,
    required bool showDayNumber,
  }) {
    final isSelected = _isSameDay(item.date, widget.selectedDate);

    final color = _heatColor(context, item.total);

    return Tooltip(
      message:
          '${item.date.day}.${item.date.month}.${item.date.year} • ${item.total.toStringAsFixed(2)}',
      child: GestureDetector(
        onTap: () => widget.onDateSelected(item.date),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: isSelected
                ? BorderRadius.circular(AppSizing.borderRadius100)
                : BorderRadius.circular(AppSizing.borderRadius4),
          ),
          alignment: Alignment.center,
          child: showDayNumber
              ? Text(
                  '${item.date.day}',
                  style: AppTextStyles.text12w400(context).copyWith(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _emptyCell({required double size}) => SizedBox(width: size, height: size);

  Widget _buildWeekdayHeaderRow(BuildContext context, {required double cellSize}) {
    return Row(
      children: Weekday.values.asMap().entries.map((entry) {
        final index = entry.key;
        final weekday = entry.value;
        return Padding(
          padding: EdgeInsets.only(right: index == 6 ? 0 : _cellGap),
          child: SizedBox(
            width: cellSize,
            child: Center(
              child: Text(
                weekday.localizedShortName(context),
                style: AppTextStyles.text12w400(context).copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _monthLabelForWeekChunk(BuildContext context, int startDayIndex) {
    final safeStart = math.max(0, startDayIndex);
    final endDayIndex = math.min(startDayIndex + 6, widget.days.length - 1);
    if (safeStart > endDayIndex) return '';
    for (int i = safeStart; i <= endDayIndex; i++) {
      final date = widget.days[i].date;
      if (date.day == 1) {
        return Month.fromValue(date.month).localizedShortName(context);
      }
    }
    return '';
  }

  Color _heatColor(BuildContext context, double value) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.primary;
    final maxValue = widget.days.fold<double>(0, (max, d) => math.max(max, d.total));

    if (value <= 0 || maxValue <= 0) {
      return colorScheme.secondary;
    }

    final ratio = (value / maxValue).clamp(0.0, 1.0);
    if (ratio < 0.2) return base.withValues(alpha: 0.25);
    if (ratio < 0.4) return base.withValues(alpha: 0.4);
    if (ratio < 0.6) return base.withValues(alpha: 0.55);
    if (ratio < 0.8) return base.withValues(alpha: 0.72);
    return base.withValues(alpha: 0.9);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _scheduleYearlyScrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.period is! YearlyPeriod) return;
      _scrollYearlyToSelected();
    });
  }

  void _scrollYearlyToSelected() {
    if (!_yearlyScrollController.hasClients || widget.days.isEmpty) return;
    final selectedDayIndex = widget.days.indexWhere(
      (d) => _isSameDay(d.date, widget.selectedDate),
    );
    if (selectedDayIndex < 0) return;

    final yearStart = DateTime(widget.days.first.date.year, 1, 1);
    final startWeekdayOffset = yearStart.weekday - 1;
    final selectedCellIndex = startWeekdayOffset + selectedDayIndex;
    final selectedWeekIndex = selectedCellIndex ~/ 7;

    final itemWidth = _yearlyCellSize + _cellGap;
    final viewportWidth = _yearlyScrollController.position.viewportDimension;
    final targetOffset =
        (selectedWeekIndex * itemWidth) - (viewportWidth / 2) + (_yearlyCellSize / 2);
    final maxOffset = _yearlyScrollController.position.maxScrollExtent;

    _yearlyScrollController.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}
