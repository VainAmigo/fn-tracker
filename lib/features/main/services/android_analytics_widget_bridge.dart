import 'package:flutter/services.dart';
import 'package:fn_tracker/features/analytics/data/models/analytics_model.dart';
import 'dart:convert';

class AndroidAnalyticsWidgetBridge {
  AndroidAnalyticsWidgetBridge._();

  static const MethodChannel _methodChannel = MethodChannel(
    'fn_tracker/android_widget/methods',
  );

  static Future<void> syncAnalytics({
    required AnalyticsModel data,
    required String periodLabel,
  }) async {
    final trendPoints = _trimToCurrentPeriod(
      data.periodSegments.map((segment) => segment.total).toList(),
      data.periodSegments.map((segment) => segment.isInitialVisible).toList(),
    );

    await _methodChannel.invokeMethod<void>('syncAnalyticsWidgetData', {
      'total_income': data.totalIncome,
      'total_expense': data.totalExpense,
      'balance': data.balance,
      'period_label': periodLabel,
      'trend_points_json': jsonEncode(trendPoints),
      'updated_at_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> clear() async {
    await _methodChannel.invokeMethod<void>('clearAnalyticsWidgetData');
  }

  static List<double> _trimToCurrentPeriod(
    List<double> values,
    List<bool> isCurrentMarker,
  ) {
    final idx = isCurrentMarker.indexWhere((v) => v);
    if (idx < 0 || idx >= values.length) return values;
    return values.sublist(0, idx + 1);
  }
}
