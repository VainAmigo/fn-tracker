part of 'analytics_cubit.dart';

sealed class AnalyticsState {}

final class AnalyticsInitial extends AnalyticsState {}

final class AnalyticsLoading extends AnalyticsState {}

final class AnalyticsLoaded extends AnalyticsState {
  AnalyticsLoaded({required this.data, required this.period});

  final AnalyticsModel data;
  final DatePickerPeriod period;
}

final class AnalyticsError extends AnalyticsState {
  AnalyticsError({required this.message});

  final String message;
}
