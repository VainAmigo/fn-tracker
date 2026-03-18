import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

abstract class AnalyticsRepoImpl {
  Future<AnalyticsModel> getAnalytics({
    required String startDayKey,
    required String endDayKey,
    required DatePickerPeriod period,
  });
}
