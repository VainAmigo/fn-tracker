import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

import 'segmented_bar.dart';

class WeeklyBarData {
  const WeeklyBarData({
    required this.label,
    required this.segments,
  });

  /// Подпись под столбцом (например, "Пн", "06").
  final String label;

  /// Сегменты столбца (используются те же цвета и модель, что и в [SegmentedBar]).
  final List<BarChartSegment> segments;

  double get total =>
      segments.fold<double>(0, (sum, seg) => sum + seg.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyBarData &&
          label == other.label &&
          listEquals(segments, other.segments);

  @override
  int get hashCode => Object.hash(label, Object.hashAll(segments));
}

class WeeklyStackedBarChart extends StatefulWidget {
  const WeeklyStackedBarChart({
    super.key,
    required this.bars,
    this.height = 160,
    this.barWidth = 18,
    this.barGap = 12,
    this.segmentGap = AppSizing.spaceBtwItemsExtra,
    this.minSegmentHeight = 6,
    this.iconSize = 16,
    this.barRadius = AppSizing.borderRadius4,
    this.labelsGap = 6,
    this.maxBarHeightFraction = 0.8,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
    this.onBarTap,
  });

  /// Данные по неделям (или любому другому периоду — виджет универсальный).
  final List<WeeklyBarData> bars;

  /// Общая высота виджета, включая подписи.
  final double height;

  /// Ширина одного столбца.
  final double barWidth;

  /// Горизонтальный зазор между столбцами.
  final double barGap;

  /// Вертикальный зазор между сегментами внутри столбца.
  final double segmentGap;

  /// Минимальная высота сегмента в пикселях (чтобы мелкие сегменты оставались видимыми).
  /// Если у сегмента есть иконка, используется max(minSegmentHeight, iconSize + 4).
  final double minSegmentHeight;

  /// Размер иконки внутри сегмента.
  final double iconSize;

  /// Радиус скругления прямоугольников.
  final double barRadius;

  /// Отступ между диаграммой и подписями.
  final double labelsGap;

  /// Доля высоты под диаграмму (остальное — подписи).
  final double maxBarHeightFraction;

  final Duration animationDuration;
  final Curve animationCurve;

  /// Коллбэк при нажатии на столбец (по индексу).
  final ValueChanged<int>? onBarTap;

  @override
  State<WeeklyStackedBarChart> createState() => _WeeklyStackedBarChartState();
}

class _WeeklyStackedBarChartState extends State<WeeklyStackedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WeeklyStackedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.bars, widget.bars)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _hitTestBar(Offset local, double width, double chartHeight) {
    if (local.dy < 0 || local.dy > chartHeight) return null;

    final n = widget.bars.length;
    if (n == 0 || width <= 0) return null;

    final cellWidth = width / n;
    final barWidth = cellWidth - widget.barGap;
    final index = (local.dx / cellWidth).floor().clamp(0, n - 1);

    final left = index * cellWidth + (cellWidth - barWidth) / 2;
    final right = left + barWidth;

    if (local.dx >= left && local.dx <= right) return index;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final labelsStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: .6),
        );

    final chartHeight = widget.height * widget.maxBarHeightFraction;

    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: (widget.maxBarHeightFraction * 100).round(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: widget.onBarTap != null
                      ? (details) {
                          final box =
                              context.findRenderObject() as RenderBox?;
                          if (box == null) return;
                          final local =
                              box.globalToLocal(details.globalPosition);
                          final index = _hitTestBar(
                            local,
                            box.size.width,
                            chartHeight,
                          );
                          if (index != null) widget.onBarTap!(index);
                        }
                      : null,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _WeeklyStackedBarChartPainter(
                          bars: widget.bars,
                          barGap: widget.barGap,
                          segmentGap: widget.segmentGap,
                          minSegmentHeight: widget.minSegmentHeight,
                          iconSize: widget.iconSize,
                          barRadius: widget.barRadius,
                          progress: _animation.value,
                          chartWidth: constraints.maxWidth,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: widget.labelsGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.bars
                .map(
                  (bar) => Expanded(
                    child: Center(
                      child: Text(
                        bar.label,
                        style: labelsStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStackedBarChartPainter extends CustomPainter {
  _WeeklyStackedBarChartPainter({
    required this.bars,
    required this.barGap,
    required this.segmentGap,
    required this.minSegmentHeight,
    required this.iconSize,
    required this.barRadius,
    required this.progress,
    required this.chartWidth,
  });

  final List<WeeklyBarData> bars;
  final double barGap;
  final double segmentGap;
  final double minSegmentHeight;
  final double iconSize;
  final double barRadius;
  final double progress;
  final double chartWidth;

  double _effectiveMinHeight(List<BarChartSegment> segments) {
    final hasIcon = segments.any((s) => s.icon != null);
    if (!hasIcon) return minSegmentHeight;
    return math.max(minSegmentHeight, iconSize + 4);
  }

  void _drawIcon(
    Canvas canvas,
    Offset center,
    IconData icon,
    double size,
    Color color,
  ) {
    final textSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily ?? 'MaterialIcons',
        fontSize: size,
        color: color,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty || progress <= 0) return;

    final maxTotal = bars
        .map((b) => b.total)
        .fold<double>(0, (a, b) => math.max(a, b));
    if (maxTotal <= 0) return;

    final n = bars.length;
    final cellWidth = chartWidth / n;
    final barWidth = cellWidth - barGap;
    final usableHeight = size.height;
    final radius = Radius.circular(barRadius);
    const iconColor = Color(0xE6FFFFFF);

    for (var i = 0; i < n; i++) {
      final bar = bars[i];
      if (bar.total <= 0) continue;

      final left = i * cellWidth + (cellWidth - barWidth) / 2;
      final right = left + barWidth;
      final barHeight = usableHeight * (bar.total / maxTotal) * progress;
      final validSegments =
          bar.segments.where((s) => s.value > 0).toList();
      final segmentCount = validSegments.length;
      final availableForSegments =
          barHeight - math.max(0, segmentCount - 1) * segmentGap;
      final effectiveMin = _effectiveMinHeight(validSegments);
      final heights = _computeSegmentHeights(
        segments: validSegments,
        available: availableForSegments,
        minHeight: effectiveMin,
      );
      var currentBottom = usableHeight;

      for (var j = 0; j < validSegments.length; j++) {
        final segment = validSegments[j];
        final height = heights[j];
        if (height <= 0) continue;

        final top = currentBottom - height;

        final rrect = RRect.fromLTRBR(
          left,
          top,
          right,
          currentBottom,
          radius,
        );

        final paint = Paint()
          ..color = segment.color
          ..style = PaintingStyle.fill;

        canvas.drawRRect(rrect, paint);

        if (segment.icon != null && height >= iconSize) {
          final center = Offset(
            (left + right) / 2,
            (top + currentBottom) / 2,
          );
          _drawIcon(
            canvas,
            center,
            segment.icon!,
            iconSize.clamp(0, height - 2),
            iconColor,
          );
        }

        currentBottom = top - segmentGap;
      }
    }
  }

  List<double> _computeSegmentHeights({
    required List<BarChartSegment> segments,
    required double available,
    required double minHeight,
  }) {
    final total = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (total <= 0) return List.filled(segments.length, 0);

    final n = segments.length;
    final heights =
        List.generate(n, (i) => (segments[i].value / total) * available);

    double deficit = 0;
    double unclampedSum = 0;

    for (var i = 0; i < n; i++) {
      if (segments[i].value > 0 && heights[i] < minHeight) {
        deficit += minHeight - heights[i];
        heights[i] = minHeight;
      } else {
        unclampedSum += heights[i];
      }
    }

    if (deficit > 0 && unclampedSum > 0) {
      for (var i = 0; i < n; i++) {
        if (heights[i] > minHeight) {
          heights[i] -= (heights[i] / unclampedSum) * deficit;
        }
      }
    }

    return heights;
  }

  @override
  bool shouldRepaint(covariant _WeeklyStackedBarChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.bars != bars ||
      oldDelegate.barGap != barGap ||
      oldDelegate.segmentGap != segmentGap ||
      oldDelegate.minSegmentHeight != minSegmentHeight ||
      oldDelegate.iconSize != iconSize ||
      oldDelegate.barRadius != barRadius ||
      oldDelegate.chartWidth != chartWidth;
}

