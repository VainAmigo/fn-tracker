import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/analytics/data/data.dart';

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({required this.analyticsRepo}) : super(AnalyticsInitial());

  final AnalyticsRepoImpl analyticsRepo;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  DatePickerPeriod? _currentPeriod;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  DatePickerPeriod? get currentPeriod => _currentPeriod;

  Future<void> loadAnalytics() async {
    _currentPeriod = MonthlyPeriod(
      year: _selectedYear,
      month: Month.fromValue(_selectedMonth),
    );
    await _loadForPeriod(_currentPeriod!);
  }

  Future<void> loadAnalyticsByPeriod(DatePickerPeriod period) async {
    _currentPeriod = period;
    switch (period) {
      case MonthlyPeriod(:final year, :final month):
        _selectedYear = year;
        _selectedMonth = month.value;
        break;
      case YearlyPeriod(:final year):
        _selectedYear = year;
        _selectedMonth = 1;
        break;
      case WeeklyPeriod(:final start):
        _selectedYear = start.year;
        _selectedMonth = start.month;
        break;
    }
    await _loadForPeriod(period);
  }

  Future<void> _loadForPeriod(DatePickerPeriod period) async {
    try {
      emit(AnalyticsLoading());
      final data = await analyticsRepo.getAnalytics(
        startDayKey: period.startDayKey,
        endDayKey: period.endDayKey,
        period: period,
      );
      emit(AnalyticsLoaded(data: data, period: period));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }
}
