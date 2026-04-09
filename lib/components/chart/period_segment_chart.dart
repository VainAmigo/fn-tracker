import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Данные для одного сегмента (день/месяц) на диаграмме.
class PeriodSegmentData {
  const PeriodSegmentData({
    required this.label,
    required this.total,
    required this.segments,
    this.isInitialVisible = false,
  });

  /// Подпись под столбцом (например "21 MAR", "JAN").
  final String label;

  /// Общая сумма за период.
  final double total;

  /// Разбивка по категориям (цвет, сумма, название).
  final List<CategorySegmentData> segments;

  /// Сегмент, который должен быть виден при старте (сегодня/текущий месяц).
  final bool isInitialVisible;

  /// Создаёт [PeriodSegmentData] из списка [CategorySpending].
  factory PeriodSegmentData.fromCategorySpendingList({
    required String label,
    required List<CategorySpending> categorySpending,
    bool isInitialVisible = false,
  }) {
    final total = categorySpending.fold<double>(0, (s, c) => s + c.amount);
    final segments = categorySpending
        .map((c) => CategorySegmentData.fromCategorySpending(c))
        .toList();
    return PeriodSegmentData(
      label: label,
      total: total,
      segments: segments,
      isInitialVisible: isInitialVisible,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodSegmentData &&
          label == other.label &&
          total == other.total &&
          listEquals(segments, other.segments) &&
          isInitialVisible == other.isInitialVisible;

  @override
  int get hashCode =>
      Object.hash(label, total, Object.hashAll(segments), isInitialVisible);
}

/// Данные категории для отображения в сегменте и в списке.
class CategorySegmentData {
  const CategorySegmentData({
    required this.value,
    required this.color,
    required this.name,
    this.icon,
  });

  final double value;
  final Color color;
  final String name;
  final IconData? icon;

  /// Создаёт [CategorySegmentData] из [CategorySpending].
  factory CategorySegmentData.fromCategorySpending(CategorySpending spending) {
    final shade = findShadeById(spending.category.colorId);
    final icon = findIconById(spending.category.iconId);
    return CategorySegmentData(
      value: spending.amount,
      color: shade?.color ?? Colors.grey,
      name: spending.category.name,
      icon: icon?.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorySegmentData &&
          value == other.value &&
          color == other.color &&
          name == other.name;

  @override
  int get hashCode => Object.hash(value, color, name);
}

/// Горизонтальная диаграмма с вертикальными сегментами.
///
/// Используется для:
/// - Год: 12 сегментов (месяцы)
/// - Месяц: 31 сегмент (дни)
/// - Неделя: 7 сегментов (дни)
///
/// Сегменты фиксированной ширины, диаграмма с горизонтальным скроллом.
/// При старте прокручивается к сегменту с [isInitialVisible].
/// При нажатии на сегмент показывается сумма сверху, разбивка по категориям
/// в столбце и список категорий под диаграммой.
///
/// Пример:
/// ```dart
/// PeriodSegmentChart(
///   bars: [
///     PeriodSegmentData(
///       label: '21 MAR',
///       total: 1500,
///       segments: [
///         CategorySegmentData.fromCategorySpending(spending1),
///         ...
///       ],
///       isInitialVisible: true, // сегодня
///     ),
///     ...
///   ],
///   currency: currency,
/// )
/// ```

const double _defaultChartHeight = 250;

class PeriodSegmentChart extends StatefulWidget {
  const PeriodSegmentChart({
    super.key,
    required this.bars,
    this.segmentWidth = AppSizing.heightM,
    this.segmentGap = AppSizing.spaceBtwItemsExtra,
    this.chartHeight = _defaultChartHeight,
    this.barRadius = AppSizing.borderRadius4,
    this.segmentGapVertical = AppSizing.spaceBtwItemsExtra,
    this.minSegmentHeight = _defaultChartHeight * 0.02,
    this.inactiveBarColor,
    this.onSegmentTap,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  });

  final List<PeriodSegmentData> bars;

  /// Фиксированная ширина одного сегмента (столбца).
  final double segmentWidth;

  /// Зазор между столбцами.
  final double segmentGap;

  /// Высота области диаграммы (без подписей и списка категорий).
  final double chartHeight;

  /// Радиус скругления столбцов.
  final double barRadius;

  /// Зазор между цветными блоками в выбранном столбце.
  final double segmentGapVertical;

  /// Минимальная высота внутреннего сегмента (цветного блока) в пикселях.
  final double minSegmentHeight;

  /// Цвет невыбранного столбца.
  final Color? inactiveBarColor;

  /// Коллбэк при нажатии на сегмент (индекс).
  final ValueChanged<int>? onSegmentTap;

  /// Длительность анимации появления.
  final Duration animationDuration;

  /// Кривая анимации.
  final Curve animationCurve;

  @override
  State<PeriodSegmentChart> createState() => _PeriodSegmentChartState();
}

class _PeriodSegmentChartState extends State<PeriodSegmentChart>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int? _selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToInitialVisible(),
    );
  }

  @override
  void didUpdateWidget(covariant PeriodSegmentChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.bars, widget.bars)) {
      _animationController.forward(from: 0);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToInitialVisible(),
      );
    }
  }

  void _scrollToInitialVisible() {
    final index = widget.bars.indexWhere((b) => b.isInitialVisible);
    if (index >= 0 && _scrollController.hasClients) {
      final itemWidth = widget.segmentWidth + widget.segmentGap;
      final viewportWidth = _scrollController.position.viewportDimension;
      final offset =
          (index * itemWidth) - (viewportWidth / 2) + (itemWidth / 2);
      _scrollController.animateTo(
        math.max(0, offset),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      if (_selectedIndex == null) {
        setState(() => _selectedIndex = index);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inactiveColor =
        widget.inactiveBarColor ?? colorScheme.onSurface.withValues(alpha: 0.2);

    final contentWidth = widget.bars.isEmpty
        ? 0.0
        : widget.bars.length * (widget.segmentWidth + widget.segmentGap) -
              widget.segmentGap;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.chartHeight + 56,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 28),
                child: SizedBox(
                  width: contentWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.bars.length, (i) {
                          final bar = widget.bars[i];
                          final hasVisibleSegments =
                              bar.total > 0 &&
                              bar.segments.any((s) => s.value > 0);
                          final isSelected = _selectedIndex == i;
                          final isLast = i == widget.bars.length - 1;
                          final barWidth = isLast
                              ? widget.segmentWidth
                              : widget.segmentWidth + widget.segmentGap;
                          return SizedBox(
                            width: barWidth,
                            child: _ChartBar(
                              bar: bar,
                              isSelected: isSelected,
                              segmentWidth: widget.segmentWidth,
                              segmentGap: widget.segmentGap,
                              chartHeight: widget.chartHeight,
                              barRadius: widget.barRadius,
                              segmentGapVertical: widget.segmentGapVertical,
                              minSegmentHeight: widget.minSegmentHeight,
                              inactiveColor: inactiveColor,
                              maxTotal: _maxTotal,
                              progress: _animation.value,
                              onTap: hasVisibleSegments
                                  ? () {
                                      setState(() => _selectedIndex = i);
                                      widget.onSegmentTap?.call(i);
                                    }
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_selectedIndex != null &&
            _selectedIndex! < widget.bars.length &&
            widget.bars[_selectedIndex!].segments.any((s) => s.value > 0)) ...[
          const SizedBox(height: AppSizing.spaceBtwItems),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => _CategoryBreakdownList(
              segments: widget.bars[_selectedIndex!].segments,
              total: widget.bars[_selectedIndex!].total,
              progress: _animation.value,
            ),
          ),
        ],
      ],
    );
  }

  double get _maxTotal {
    if (widget.bars.isEmpty) return 1;
    final max = widget.bars
        .map((b) => b.total)
        .fold<double>(0, (a, b) => math.max(a, b));
    return math.max(max, 1);
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.bar,
    required this.isSelected,
    required this.segmentWidth,
    required this.segmentGap,
    required this.chartHeight,
    required this.barRadius,
    required this.segmentGapVertical,
    required this.minSegmentHeight,
    required this.inactiveColor,
    required this.maxTotal,
    this.onTap,
    this.progress = 1.0,
  });

  final PeriodSegmentData bar;
  final bool isSelected;
  final double segmentWidth;
  final double segmentGap;
  final double chartHeight;
  final double barRadius;
  final double segmentGapVertical;
  final double minSegmentHeight;
  final Color inactiveColor;
  final double maxTotal;
  final VoidCallback? onTap;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final barHeight = maxTotal > 0 ? (bar.total / maxTotal) * chartHeight : 0.0;
    final hasVisibleSegments = bar.total > 0 && bar.segments.any((s) => s.value > 0);
    final radius = Radius.circular(barRadius);

    final barWidget = !hasVisibleSegments
        ? const SizedBox.shrink()
        : isSelected
        ? _StackedBar(
            segments: bar.segments,
            width: segmentWidth,
            totalHeight: barHeight * progress,
            total: bar.total,
            maxTotal: maxTotal,
            radius: radius,
            segmentGap: segmentGapVertical,
            minSegmentHeight: minSegmentHeight,
            progress: progress,
          )
        : Container(
            width: segmentWidth,
            height: (barHeight * progress).clamp(4, chartHeight),
            decoration: BoxDecoration(
              color: inactiveColor,
              borderRadius: BorderRadius.all(radius),
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hasVisibleSegments ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: segmentWidth,
            height: chartHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Align(alignment: Alignment.bottomCenter, child: barWidget),
                if (isSelected && hasVisibleSegments)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: barHeight * progress + 4,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AmountTextWidget(
                          amount: bar.total,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: AppTextStyles.text14w400(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: segmentWidth + segmentGap,
            child: Text(
              bar.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({
    required this.segments,
    required this.width,
    required this.totalHeight,
    required this.total,
    required this.maxTotal,
    required this.radius,
    required this.segmentGap,
    required this.minSegmentHeight,
    this.progress = 1.0,
  });

  final List<CategorySegmentData> segments;
  final double width;
  final double totalHeight;
  final double total;
  final double maxTotal;
  final Radius radius;
  final double segmentGap;
  final double minSegmentHeight;
  final double progress;

  List<double> _computeSegmentHeights(
    List<CategorySegmentData> validSegments,
    double available,
  ) {
    final totalValue = validSegments.fold<double>(0, (s, e) => s + e.value);
    if (totalValue <= 0) return List.filled(validSegments.length, 0);

    final n = validSegments.length;
    var heights = validSegments
        .map((s) => (s.value / totalValue) * available)
        .toList();

    double deficit = 0;
    double unclampedSum = 0;

    for (var i = 0; i < n; i++) {
      if (validSegments[i].value > 0 && heights[i] < minSegmentHeight) {
        deficit += minSegmentHeight - heights[i];
        heights[i] = minSegmentHeight;
      } else {
        unclampedSum += heights[i];
      }
    }

    if (deficit > 0 && unclampedSum > 0) {
      for (var i = 0; i < n; i++) {
        if (heights[i] > minSegmentHeight) {
          heights[i] -= (heights[i] / unclampedSum) * deficit;
        }
      }
    }

    var totalHeights = heights.fold<double>(0, (a, b) => a + b);
    if (totalHeights > available && totalHeights > 0) {
      final safeAvailable = math.max(0, available - 2);
      final scale = safeAvailable / totalHeights;
      heights = heights.map((h) => h * scale).toList();
    }

    return heights;
  }

  @override
  Widget build(BuildContext context) {
    final validSegments = segments.where((s) => s.value > 0).toList();
    if (validSegments.isEmpty) return const SizedBox.shrink();

    final totalValue = validSegments.fold<double>(0, (s, e) => s + e.value);
    if (totalValue <= 0) return const SizedBox.shrink();

    final safeTotalHeight = totalHeight.clamp(4, double.infinity).toDouble();
    final gapsCount = math.max(0, validSegments.length - 1);
    var effectiveGap = segmentGap;
    var availableHeight = safeTotalHeight - gapsCount * effectiveGap;
    if (availableHeight <= 0) {
      effectiveGap = 0;
      availableHeight = safeTotalHeight;
    }
    final heights = _computeSegmentHeights(validSegments, availableHeight);

    return SizedBox(
      width: width,
      height: safeTotalHeight,
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var i = 0; i < validSegments.length; i++) ...[
              if (i > 0) SizedBox(height: effectiveGap),
              Container(
                width: width,
                height: math.max(0.0, heights[i] * progress),
                decoration: BoxDecoration(
                  color: validSegments[i].color,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? radius : Radius.zero,
                    bottom: i == validSegments.length - 1
                        ? radius
                        : Radius.zero,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({
    required this.segments,
    required this.total,
    this.progress = 1.0,
  });

  final List<CategorySegmentData> segments;
  final double total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final validSegments = segments.where((s) => s.value > 0).toList();
    if (validSegments.isEmpty) return const SizedBox.shrink();

    final maxValue = validSegments
        .map((s) => s.value)
        .fold<double>(0, (a, b) => math.max(a, b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < validSegments.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSizing.spaceBtwItems),
          _CategoryBreakdownRow(
            segment: validSegments[i],
            maxValue: maxValue,
            colorScheme: colorScheme,
            progress: progress,
          ),
        ],
      ],
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  const _CategoryBreakdownRow({
    required this.segment,
    required this.maxValue,
    required this.colorScheme,
    this.progress = 1.0,
  });

  static const double _minBarWidth = 90;
  static const double _maxBarWidth = 200;
  static const double _barHeight = AppSizing.heightS;

  final CategorySegmentData segment;
  final double maxValue;
  final ColorScheme colorScheme;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue > 0
        ? (segment.value / maxValue).clamp(0.0, 1.0)
        : 0.0;
    final barWidth =
        _minBarWidth + (_maxBarWidth - _minBarWidth) * fraction * progress;

    return Row(
      children: [
        Container(
          height: AppSizing.heightS,
          width: AppSizing.heightS,
          decoration: BoxDecoration(
            color: segment.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
          ),
          child: Icon(
            segment.icon ?? Icons.category,
            size: AppSizing.iconSizeM,
            color: segment.color,
          ),
        ),
        const SizedBox(width: AppSizing.spaceBtwItems),
        Expanded(
          child: Text(
            segment.name,
            style: AppTextStyles.listTileTitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSizing.spaceBtwItems),
        Container(
          height: _barHeight,
          constraints: BoxConstraints(minWidth: _minBarWidth),
          width: barWidth,
          decoration: BoxDecoration(
            color: segment.color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding / 2,
          ),
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: AmountTextWidget(
              amount: segment.value,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyles.text14w400(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
