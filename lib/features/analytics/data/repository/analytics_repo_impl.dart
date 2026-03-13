import 'package:fn_tracker/features/features.dart';

abstract class AnalyticsRepoImpl {
  Future<AnalyticsPeriodModel> getAnalytics({
    required String startDayKey,
    required String endDayKey,
  });
}
