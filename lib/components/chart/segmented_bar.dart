import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BarChartSegment {
  const BarChartSegment({
    required this.value,
    required this.color,
    this.icon,
  });

  final double value;
  final Color color;

  /// Иконка внутри сегмента (для stacked bar chart).
  final IconData? icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarChartSegment &&
          value == other.value &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(value, color, icon);
}

class SegmentedBar extends StatefulWidget {
  const SegmentedBar({
    super.key,
    required this.segments,
    this.height = 12,
    this.gap = 4,
    this.minFraction = 0.06,
    this.trackColor,
    this.onSegmentTap,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  });

  final List<BarChartSegment> segments;
  final double height;

  /// Зазор между сегментами в пикселях.
  final double gap;

  /// Минимальная доля ширины сегмента (0.0–1.0) от доступного пространства.
  final double minFraction;

  final Color? trackColor;
  final ValueChanged<int>? onSegmentTap;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<SegmentedBar> createState() => _SegmentedBarState();
}

class _SegmentedBarState extends State<SegmentedBar>
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
  void didUpdateWidget(covariant SegmentedBar oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final trackColor =
        widget.trackColor ?? Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTapUp: widget.onSegmentTap != null
          ? (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final index = _hitTest(details.localPosition, box.size.width);
              if (index != null) widget.onSegmentTap!(index);
            }
          : null,
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return CustomPaint(
              painter: _SegmentedBarPainter(
                segments: widget.segments,
                gap: widget.gap,
                minFraction: widget.minFraction,
                trackColor: trackColor,
                progress: _animation.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  int? _hitTest(Offset local, double totalWidth) {
    if (local.dy < 0 || local.dy > widget.height) return null;

    final n = widget.segments.length;
    final available = totalWidth - math.max(0, n - 1) * widget.gap;
    if (available <= 0) return null;

    final widths = _computeWidths(
      segments: widget.segments,
      available: available,
      minWidth: widget.minFraction * available,
    );

    double cursor = 0;
    for (int i = 0; i < n; i++) {
      final end = cursor + widths[i];
      if (local.dx >= cursor && local.dx <= end) return i;
      cursor = end + widget.gap;
    }
    return null;
  }
}

List<double> _computeWidths({
  required List<BarChartSegment> segments,
  required double available,
  required double minWidth,
}) {
  final total = segments.fold<double>(0, (s, seg) => s + seg.value);
  if (total <= 0) return List.filled(segments.length, 0);

  final n = segments.length;
  final widths =
      List.generate(n, (i) => (segments[i].value / total) * available);

  double deficit = 0;
  double unclampedSum = 0;

  for (int i = 0; i < n; i++) {
    if (segments[i].value > 0 && widths[i] < minWidth) {
      deficit += minWidth - widths[i];
      widths[i] = minWidth;
    } else {
      unclampedSum += widths[i];
    }
  }

  if (deficit > 0 && unclampedSum > 0) {
    for (int i = 0; i < n; i++) {
      if (widths[i] > minWidth) {
        widths[i] -= (widths[i] / unclampedSum) * deficit;
      }
    }
  }

  return widths;
}

class _SegmentedBarPainter extends CustomPainter {
  final List<BarChartSegment> segments;
  final double gap;
  final double minFraction;
  final Color trackColor;
  final double progress;

  _SegmentedBarPainter({
    required this.segments,
    required this.gap,
    required this.minFraction,
    required this.trackColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRRect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      radius,
    );
    canvas.drawRRect(trackRRect, Paint()..color = trackColor);

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0 || progress <= 0) return;

    final n = segments.length;
    final available = size.width - math.max(0, n - 1) * gap;
    if (available <= 0) return;

    final widths = _computeWidths(
      segments: segments,
      available: available,
      minWidth: minFraction * available,
    );

    double cursor = 0;

    for (int i = 0; i < n; i++) {
      final w = widths[i] * progress;
      if (w <= 0) {
        cursor += widths[i] + gap;
        continue;
      }

      final segRect = RRect.fromLTRBR(cursor, 0, cursor + w, size.height, radius);
      canvas.drawRRect(segRect, Paint()..color = segments[i].color);

      cursor += widths[i] + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.segments != segments ||
      oldDelegate.gap != gap ||
      oldDelegate.minFraction != minFraction ||
      oldDelegate.trackColor != trackColor;
}
