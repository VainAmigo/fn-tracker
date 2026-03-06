import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';

class BudgetChartData {
  final List<DonutChartSegment> segments;
  final Color accentColor;

  const BudgetChartData({required this.segments, required this.accentColor});

  factory BudgetChartData.from({
    required double budget,
    required double spent,
    required ColorScheme colorScheme,
  }) {
    if (budget <= 0) {
      return BudgetChartData(segments: [], accentColor: colorScheme.onSurface);
    }

    final exceeded = spent > budget;

    if (exceeded) {
      return BudgetChartData(
        segments: [
          DonutChartSegment(value: budget, color: colorScheme.secondary),
          DonutChartSegment(value: spent - budget, color: colorScheme.error),
        ],
        accentColor: colorScheme.error,
      );
    }

    return BudgetChartData(
      segments: [
        DonutChartSegment(value: spent, color: colorScheme.primary),
        DonutChartSegment(value: budget - spent, color: colorScheme.secondary),
      ],
      accentColor: colorScheme.primary,
    );
  }
}
