import 'dart:math' as math;
import 'package:flutter/material.dart';

/// How to use
/// 1. Create a list of values
/// SizedBox(
///   height: height * 0.6,
///   width: double.infinity,
///   child: CustomPaint(
///     painter: StaticLineChartPainter(
///       values: values,
///       minYFactor: 0.3,
///       gradientColor: colorScheme.tertiary,
///     ),
///   ),
/// ),
class StaticLineChartPainter extends CustomPainter {
  final List<double> values;
  final double minYFactor;
  final Color gradientColor;

  StaticLineChartPainter({
    required this.values,
    this.minYFactor = 0.6,
    this.gradientColor = const Color(0xFFFFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);

    // max → верх контейнера, min → minYFactor
    final maxY = 0.0;
    final minY = size.height * minYFactor;
    final chartHeight = minY - maxY;

    final stepX = size.width / (values.length - 1);
    final valueRange = maxValue - minValue;

    double mapY(double value) {
      if (valueRange <= 0) return maxY;
      final t = ((value - minValue) / valueRange).clamp(0.0, 1.0);
      return maxY + (1 - t) * chartHeight; // maxValue -> top, minValue -> bottom
    }

    /// --- ЛИНИЯ ---
    final linePath = Path();
    linePath.moveTo(0, mapY(values.first));

    for (int i = 1; i < values.length; i++) {
      final prevX = stepX * (i - 1);
      final prevY = mapY(values[i - 1]);
      final x = stepX * i;
      final y = mapY(values[i]);

      final cx = (prevX + x) / 2;

      linePath.cubicTo(
        cx, prevY,
        cx, y,
        x, y,
      );
    }

    /// --- ЗАЛИВКА (от линии диаграммы до низа контейнера) ---
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    /// Градиент на всю высоту контейнера (от верха до низа)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        gradientColor.withValues(alpha: .6),
        gradientColor.withValues(alpha: .0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    /// --- ЛИНИЯ ---
    final linePaint = Paint()
      ..color = gradientColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant StaticLineChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.minYFactor != minYFactor;
}
