import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class AnalyticsTrendChartWidget extends StatelessWidget {
  const AnalyticsTrendChartWidget({
    required this.monthlyTrend,
    required this.formatter,
    super.key,
  });

  final List<MonthlyTrendItem> monthlyTrend;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expenseValues =
        monthlyTrend.map((m) => m.expense).toList(growable: false);
    final values = expenseValues.length == 1
        ? <double>[expenseValues.first, expenseValues.first]
        : expenseValues;

    return TitledSection(
      title: 'Динамика расходов',
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: StaticLineChartPainter(
              values: values,
              minYFactor: 0.3,
              gradientColor: colorScheme.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}
