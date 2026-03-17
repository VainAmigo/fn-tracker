part of 'scheduled_payments_cubit.dart';

sealed class ScheduledPaymentsState {}

class ScheduledPaymentsInitial extends ScheduledPaymentsState {}

class ScheduledPaymentsLoading extends ScheduledPaymentsState {}

class ScheduledPaymentsLoaded extends ScheduledPaymentsState {
  ScheduledPaymentsLoaded({required this.payments});

  final List<ScheduledPaymentModel> payments;
}

class ScheduledPaymentsError extends ScheduledPaymentsState {
  ScheduledPaymentsError({required this.message});

  final String message;
}
