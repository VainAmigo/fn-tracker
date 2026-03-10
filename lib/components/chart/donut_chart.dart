import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DonutChartSegment {
  final double value;
  final Color color;
  final Widget? icon;

  const DonutChartSegment({
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonutChartSegment &&
          value == other.value &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(value, color, icon);
}

class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 280,
    this.strokeWidth = 14,
    this.gapDegrees = 5,
    this.minSweepDegrees = 20,
    this.minSegmentValue,
    this.iconSize = 32,
    this.trackColor,
    this.startAngle = -90,
    this.child,
    this.onSegmentTap,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  });

  final List<DonutChartSegment> segments;
  final double size;
  final double strokeWidth;

  /// Видимый зазор между закруглёнными концами сегментов (в градусах).
  final double gapDegrees;

  /// Минимальная угловая ширина сегмента (в градусах).
  final double minSweepDegrees;

  /// Минимальное значение сегмента — сегменты с value < minSegmentValue
  /// исключаются из отображения.
  final double? minSegmentValue;

  /// Размер иконки в сегменте.
  final double iconSize;

  final Color? trackColor;

  /// Начальный угол в градусах (по умолчанию -90 = 12 часов).
  final double startAngle;
  final Widget? child;
  final ValueChanged<int>? onSegmentTap;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
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
  void didUpdateWidget(covariant DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.segments, widget.segments)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _hitTestSegment(Offset localPosition, List<DonutChartSegment> segments) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final radius = (widget.size - widget.strokeWidth) / 2;
    final outerRadius = radius + widget.strokeWidth / 2;
    final innerRadius = radius - widget.strokeWidth / 2;
    if (distance < innerRadius || distance > outerRadius) return null;

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return null;

    var angle = math.atan2(dy, dx) * 180 / math.pi;
    angle = (angle - widget.startAngle) % 360;

    final segmentCount = segments.length;
    final totalGapDeg = segmentCount > 1 ? widget.gapDegrees * segmentCount : 0;
    final availableDeg = 360.0 - totalGapDeg;

    final sweeps = _computeSweepsDeg(
      segments: segments,
      availableDeg: availableDeg,
      minSweepDeg: widget.minSweepDegrees,
    );

    double cursor = 0;
    for (int i = 0; i < segmentCount; i++) {
      if (angle >= cursor && angle <= cursor + sweeps[i]) return i;
      cursor += sweeps[i] + widget.gapDegrees;
    }
    return null;
  }

  List<DonutChartSegment> get _filteredSegments {
    final minVal = widget.minSegmentValue;
    if (minVal == null || minVal <= 0) return widget.segments;
    return widget.segments.where((s) => s.value >= minVal).toList();
  }

  @override
  Widget build(BuildContext context) {
    final trackColor =
        widget.trackColor ?? Theme.of(context).colorScheme.surface;
    final segments = _filteredSegments;

    return GestureDetector(
      onTapUp: widget.onSegmentTap != null
          ? (details) {
              final index = _hitTestSegment(details.localPosition, segments);
              if (index != null) widget.onSegmentTap!(index);
            }
          : null,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _DonutChartPainter(
                    segments: segments,
                    strokeWidth: widget.strokeWidth,
                    gapDegrees: widget.gapDegrees,
                    minSweepDegrees: widget.minSweepDegrees,
                    trackColor: trackColor,
                    startAngle: widget.startAngle,
                    progress: _animation.value,
                  ),
                ),
                if (segments.any((s) => s.icon != null))
                  _SegmentIconsOverlay(
                    segments: segments,
                    size: widget.size,
                    strokeWidth: widget.strokeWidth,
                    iconSize: widget.iconSize,
                    startAngle: widget.startAngle,
                    gapDegrees: widget.gapDegrees,
                    minSweepDegrees: widget.minSweepDegrees,
                    progress: _animation.value,
                  ),
                ...?(child != null ? [child] : null),
              ],
            );
          },
          child: widget.child != null
              ? Center(child: widget.child!)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _SegmentIconsOverlay extends StatelessWidget {
  const _SegmentIconsOverlay({
    required this.segments,
    required this.size,
    required this.strokeWidth,
    required this.iconSize,
    required this.startAngle,
    required this.gapDegrees,
    required this.minSweepDegrees,
    required this.progress,
  });

  final List<DonutChartSegment> segments;
  final double size;
  final double strokeWidth;
  final double iconSize;
  final double startAngle;
  final double gapDegrees;
  final double minSweepDegrees;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (total <= 0 || progress <= 0) return const SizedBox.shrink();

    final n = segments.length;
    final totalGap = n > 1 ? gapDegrees * n : 0;
    final available = 360.0 - totalGap;
    final sweeps = _computeSweepsDeg(
      segments: segments,
      availableDeg: available,
      minSweepDeg: minSweepDegrees,
    );

    final ringRadius = (size - strokeWidth) / 2;
    final center = size / 2;

    final minSegmentIconSize = math.min(iconSize, strokeWidth * 0.75);

    var cursorDeg = startAngle;
    final iconWidgets = <Widget>[];
    for (var i = 0; i < n; i++) {
      if (segments[i].icon != null && sweeps[i] * progress >= 16) {
        final sweepDeg = sweeps[i] * progress;
        final isMinWidth = sweepDeg <= minSweepDegrees + 2;
        iconWidgets.add(
          _PositionedSegmentIcon(
            icon: segments[i].icon!,
            centerAngleDeg: cursorDeg + sweeps[i] / 2,
            radius: ringRadius,
            chartCenter: center,
            iconSize: isMinWidth ? minSegmentIconSize : iconSize,
          ),
        );
      }
      cursorDeg += sweeps[i] + (n > 1 ? gapDegrees : 0);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: iconWidgets),
    );
  }
}

class _PositionedSegmentIcon extends StatelessWidget {
  const _PositionedSegmentIcon({
    required this.icon,
    required this.centerAngleDeg,
    required this.radius,
    required this.chartCenter,
    required this.iconSize,
  });

  final Widget icon;
  final double centerAngleDeg;
  final double radius;
  final double chartCenter;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final angleRad = centerAngleDeg * math.pi / 180;
    final half = iconSize / 2;
    final x = chartCenter + radius * math.cos(angleRad);
    final y = chartCenter + radius * math.sin(angleRad);
    return Positioned(
      left: x - half,
      top: y - half,
      width: iconSize,
      height: iconSize,
      child: Center(
        child: FittedBox(fit: BoxFit.contain, child: icon),
      ),
    );
  }
}

List<double> _computeSweepsDeg({
  required List<DonutChartSegment> segments,
  required double availableDeg,
  required double minSweepDeg,
}) {
  final total = segments.fold<double>(0, (s, seg) => s + seg.value);
  if (total <= 0) return List.filled(segments.length, 0);

  final n = segments.length;
  final sweeps = List.generate(
    n,
    (i) => (segments[i].value / total) * availableDeg,
  );

  double deficit = 0;
  double unclampedSum = 0;

  for (int i = 0; i < n; i++) {
    if (segments[i].value > 0 && sweeps[i] < minSweepDeg) {
      deficit += minSweepDeg - sweeps[i];
      sweeps[i] = minSweepDeg;
    } else {
      unclampedSum += sweeps[i];
    }
  }

  if (deficit > 0 && unclampedSum > 0) {
    for (int i = 0; i < n; i++) {
      if (sweeps[i] > minSweepDeg) {
        sweeps[i] -= (sweeps[i] / unclampedSum) * deficit;
      }
    }
  }

  return sweeps;
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutChartSegment> segments;
  final double strokeWidth;
  final double gapDegrees;
  final double minSweepDegrees;
  final Color trackColor;
  final double startAngle;
  final double progress;

  _DonutChartPainter({
    required this.segments,
    required this.strokeWidth,
    required this.gapDegrees,
    required this.minSweepDegrees,
    required this.trackColor,
    required this.startAngle,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0 || progress <= 0) return;

    final segmentCount = segments.length;
    final totalGapDeg = segmentCount > 1 ? gapDegrees * segmentCount : 0;
    final availableDeg = 360.0 - totalGapDeg;

    final sweepsDeg = _computeSweepsDeg(
      segments: segments,
      availableDeg: availableDeg,
      minSweepDeg: minSweepDegrees,
    );

    final capRad = strokeWidth / (2 * radius);
    final startRad = startAngle * math.pi / 180;
    final gapRad = segmentCount > 1 ? gapDegrees * math.pi / 180 : 0.0;

    double cursor = startRad;

    for (int i = 0; i < segmentCount; i++) {
      final sweepDeg = sweepsDeg[i] * progress;
      final sweepRad = sweepDeg * math.pi / 180;
      final isMinWidth = sweepDeg <= minSweepDegrees + 2;

      if (sweepRad > 0) {
        if (isMinWidth && segmentCount > 1) {
          final centerAngleRad = cursor + sweepRad / 2;
          final dotCenter = Offset(
            center.dx + radius * math.cos(centerAngleRad),
            center.dy + radius * math.sin(centerAngleRad),
          );
          final dotPaint = Paint()
            ..color = segments[i].color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(dotCenter, strokeWidth / 2, dotPaint);
        } else {
          final paint = Paint()
            ..color = segments[i].color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;

          final inset = segmentCount > 1 ? math.min(capRad, sweepRad / 3) : 0.0;
          final drawSweep = sweepRad - 2 * inset;

          canvas.drawArc(rect, cursor + inset, drawSweep, false, paint);
        }
      }

      cursor += sweepsDeg[i] * math.pi / 180 * progress + gapRad * progress;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.segments != segments ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gapDegrees != gapDegrees ||
      oldDelegate.minSweepDegrees != minSweepDegrees ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.startAngle != startAngle;
}
