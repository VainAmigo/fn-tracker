import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'scheduled_payments_state.dart';

class ScheduledPaymentsCubit extends Cubit<ScheduledPaymentsState> {
  ScheduledPaymentsCubit({required this.walletRepo})
      : super(ScheduledPaymentsInitial());

  final WalletRepoImpl walletRepo;

  Future<void> loadPayments() async {
    emit(ScheduledPaymentsLoading());
    try {
      final payments = await walletRepo.getScheduledPayments();
      emit(ScheduledPaymentsLoaded(payments: payments));
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> createPayment(ScheduledPaymentModel payment) async {
    final current = state;
    if (current is! ScheduledPaymentsLoaded) return;
    try {
      final created = await walletRepo.createScheduledPayment(payment: payment);
      emit(ScheduledPaymentsLoaded(
        payments: [created, ...current.payments],
      ));
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> updatePayment(ScheduledPaymentModel payment) async {
    final current = state;
    if (current is! ScheduledPaymentsLoaded) return;
    try {
      final updated = await walletRepo.updateScheduledPayment(payment: payment);
      final list = current.payments.map((p) {
        if (p.id == updated.id) return updated;
        return p;
      }).toList();
      emit(ScheduledPaymentsLoaded(payments: list));
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> deletePayment(String id) async {
    final current = state;
    if (current is! ScheduledPaymentsLoaded) return;
    try {
      await walletRepo.deleteScheduledPayment(id);
      emit(ScheduledPaymentsLoaded(
        payments: current.payments.where((p) => p.id != id).toList(),
      ));
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> togglePause(String id) async {
    final current = state;
    if (current is! ScheduledPaymentsLoaded) return;
    final payment = current.payments.firstWhere((p) => p.id == id);
    await updatePayment(payment.copyWith(isPaused: !payment.isPaused));
  }

  List<ScheduledPaymentModel> get currentPayments =>
      state is ScheduledPaymentsLoaded
          ? (state as ScheduledPaymentsLoaded).payments
          : [];
}
