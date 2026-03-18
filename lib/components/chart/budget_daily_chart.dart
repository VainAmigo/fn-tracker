import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Компактный горизонтальный график с вертикальными сегментами для отображения
/// расходов по дням (например, за месяц). Поддерживает опциональную ступенчатую
/// линию порога (бюджета), которая может меняться в течение периода.
///
/// Пример использования для бюджета:
/// ```dart
/// BudgetDailyChart(
///   values: [100, 50, 200, ...],  // траты за каждый день
///   thresholdValues: [80, 80, 100, 100, ...],  // лимит бюджета по дням (может меняться)
///   // или thresholdValues: null — без линии
/// )
/// ```
class BudgetDailyChart extends StatelessWidget {
  const BudgetDailyChart({
    super.key,
    required this.values,
    this.thresholdValues,
    this.height = 24,
    this.gap = 2,
    this.minSegmentWidth = 4,
    this.barColor,
    this.exceededColor,
    this.thresholdLineColor,
    this.thresholdLineWidth = 1.5,
  });

  /// Суммы потраченные за каждый день периода (28–31 значение для месяца).
  final List<double> values;

  /// Лимит бюджета для каждого дня. Длина должна совпадать с [values].
  /// Если null — линия порога не отображается.
  /// Позволяет задать разный бюджет в разные дни (например, изменение в середине месяца).
  final List<double>? thresholdValues;

  /// Высота графика (компактный виджет).
  final double height;

  /// Зазор между сегментами в пикселях.
  final double gap;

  /// Минимальная ширина сегмента в пикселях. При достижении — включается скролл.
  final double minSegmentWidth;

  /// Цвет обычного сегмента (ниже порога).
  final Color? barColor;

  /// Цвет сегмента при превышении порога.
  final Color? exceededColor;

  /// Цвет линии порога (ступенчатая).
  final Color? thresholdLineColor;

  /// Толщина линии порога.
  final double thresholdLineWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBarColor = barColor ?? colorScheme.onSurface.withValues(alpha: 0.25);
    final effectiveExceededColor = exceededColor ?? colorScheme.error;
    final effectiveThresholdColor =
        thresholdLineColor ?? colorScheme.tertiary;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final n = values.length;
          if (n == 0) return const SizedBox.shrink();

          final totalGap = math.max(0, n - 1) * gap;
          final availableWidth = containerWidth - totalGap;
          final segmentWidth = (availableWidth / n).clamp(minSegmentWidth, double.infinity);
          final contentWidth = n * segmentWidth + totalGap;
          final needsScroll = contentWidth > containerWidth;

          final child = CustomPaint(
            size: Size(contentWidth, height),
            painter: _BudgetDailyChartPainter(
              values: values,
              thresholdValues: thresholdValues,
              gap: gap,
              segmentWidth: segmentWidth,
              barColor: effectiveBarColor,
              exceededColor: effectiveExceededColor,
              thresholdLineColor: effectiveThresholdColor,
              thresholdLineWidth: thresholdLineWidth,
            ),
          );

          if (needsScroll) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: child,
            );
          }

          return child;
        },
      ),
    );
  }
}

class _BudgetDailyChartPainter extends CustomPainter {
  _BudgetDailyChartPainter({
    required this.values,
    required this.thresholdValues,
    required this.gap,
    required this.segmentWidth,
    required this.barColor,
    required this.exceededColor,
    required this.thresholdLineColor,
    required this.thresholdLineWidth,
  });

  final List<double> values;
  final List<double>? thresholdValues;
  final double gap;
  final double segmentWidth;
  final Color barColor;
  final Color exceededColor;
  final Color thresholdLineColor;
  final double thresholdLineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;

    final maxValue = values.fold<double>(0, (a, v) => math.max(a, v));
    final maxThreshold = thresholdValues != null && thresholdValues!.length == n
        ? thresholdValues!.fold<double>(0, (a, v) => math.max(a, v))
        : 0.0;
    final range = math.max(math.max(maxValue, maxThreshold), 1.0);

    double valueToY(double value) {
      return size.height - (value / range) * size.height;
    }

    final radius = Radius.circular(segmentWidth / 2);

    for (int i = 0; i < n; i++) {
      final left = i * (segmentWidth + gap);
      final right = left + segmentWidth;
      final value = values[i];
      final barHeight = (value / range) * size.height;
      final top = size.height - barHeight;

      final threshold = thresholdValues != null &&
              i < thresholdValues!.length
          ? thresholdValues![i]
          : null;
      final exceeds = threshold != null && value > threshold;
      final color = exceeds ? exceededColor : barColor;

      final rrect = RRect.fromLTRBR(left, top, right, size.height, radius);
      canvas.drawRRect(rrect, Paint()..color = color);
    }

    if (thresholdValues != null &&
        thresholdValues!.length == n &&
        thresholdValues!.any((v) => v > 0)) {
      _drawSteppedLine(canvas, size, valueToY);
    }
  }

  void _drawSteppedLine(Canvas canvas, Size size, double Function(double) valueToY) {
    final n = thresholdValues!.length;
    if (n == 0) return;

    double centerXAt(int i) {
      final left = i * (segmentWidth + gap);
      return left + segmentWidth / 2;
    }

    final path = Path();
    path.moveTo(0, valueToY(thresholdValues![0]));

    for (int i = 0; i < n; i++) {
      final y = valueToY(thresholdValues![i]);
      final cx = centerXAt(i);
      if (i == 0) {
        path.lineTo(cx, y);
      } else {
        path.lineTo(centerXAt(i - 1), y);
        path.lineTo(cx, y);
      }
    }
    path.lineTo(size.width, valueToY(thresholdValues![n - 1]));

    final paint = Paint()
      ..color = thresholdLineColor
      ..strokeWidth = thresholdLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BudgetDailyChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.thresholdValues != thresholdValues ||
      oldDelegate.gap != gap ||
      oldDelegate.segmentWidth != segmentWidth ||
      oldDelegate.barColor != barColor ||
      oldDelegate.exceededColor != exceededColor ||
      oldDelegate.thresholdLineColor != thresholdLineColor ||
      oldDelegate.thresholdLineWidth != thresholdLineWidth;
}
