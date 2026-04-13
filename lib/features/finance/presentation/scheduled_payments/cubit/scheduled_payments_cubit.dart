import 'package:fn_tracker/features/features.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'scheduled_payments_state.dart';

class ScheduledPaymentsCubit extends HydratedCubit<ScheduledPaymentsState> {
  ScheduledPaymentsCubit({required this.financeRepo})
      : super(ScheduledPaymentsInitial());

  final FinanceRepoImpl financeRepo;

  @override
  String get storagePrefix => 'ScheduledPaymentsCubit';

  @override
  ScheduledPaymentsState? fromJson(Map<String, dynamic> json) {
    final type = json['_type'] as String?;
    if (type == 'loaded') {
      final payments = (json['payments'] as List)
          .map((e) => ScheduledPaymentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ScheduledPaymentsLoaded(payments: payments);
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ScheduledPaymentsState state) {
    if (state is ScheduledPaymentsLoading ||
        state is ScheduledPaymentsInitial ||
        state is ScheduledPaymentsError) {
      return null; // Do not persist — keep previous cached state
    }
    if (state is ScheduledPaymentsLoaded) {
      return {
        '_type': 'loaded',
        'payments': state.payments.map(_paymentToJson).toList(),
      };
    }
    return null;
  }

  Map<String, dynamic> _paymentToJson(ScheduledPaymentModel p) {
    return {
      'id': p.id,
      'name': p.name,
      'amount': p.amount,
      'nextDate': p.nextDate.toIso8601String(),
      'iconId': p.iconId,
      'colorId': p.colorId,
      'type': p.type.toJson(),
      'frequency': p.frequency.toJson(),
      'frequencyInterval': p.frequencyInterval,
      'autoCreateTransaction': p.autoCreateTransaction,
      'isPaused': p.isPaused,
      'walletId': p.walletId,
      'goalId': p.goalId,
      'categoryId': p.categoryId,
      'paymentDate': p.paymentDate?.toIso8601String(),
      'monthDays': p.monthDays,
      'yearlyDates': p.yearlyDates,
      'createdAt': p.createdAt?.toIso8601String(),
      'updatedAt': p.updatedAt?.toIso8601String(),
    };
  }

  void clearForLogout() => emit(ScheduledPaymentsInitial());

  Future<void> loadPayments() async {
    emit(ScheduledPaymentsLoading());
    try {
      final payments = await financeRepo.getScheduledPayments();
      emit(ScheduledPaymentsLoaded(payments: payments));
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> createPayment(ScheduledPaymentModel payment) async {
    try {
      final created = await financeRepo.createScheduledPayment(payment: payment);
      final current = state;
      if (current is ScheduledPaymentsLoaded) {
        emit(ScheduledPaymentsLoaded(payments: [created, ...current.payments]));
      } else {
        emit(ScheduledPaymentsLoaded(payments: [created]));
      }
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> updatePayment(ScheduledPaymentModel payment) async {
    try {
      final updated = await financeRepo.updateScheduledPayment(payment: payment);
      final current = state;
      if (current is ScheduledPaymentsLoaded) {
        final list = current.payments.map((p) {
          if (p.id == updated.id) return updated;
          return p;
        }).toList();
        emit(ScheduledPaymentsLoaded(payments: list));
      } else {
        emit(ScheduledPaymentsLoaded(payments: [updated]));
      }
    } catch (e) {
      emit(ScheduledPaymentsError(message: e.toString()));
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await financeRepo.deleteScheduledPayment(id);
      final current = state;
      if (current is ScheduledPaymentsLoaded) {
        emit(
          ScheduledPaymentsLoaded(
            payments: current.payments.where((p) => p.id != id).toList(),
          ),
        );
      } else {
        emit(ScheduledPaymentsLoaded(payments: []));
      }
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
