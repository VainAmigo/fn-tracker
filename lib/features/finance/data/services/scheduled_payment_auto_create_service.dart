import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

/// Сервис автосоздания транзакций для плановых платежей.
class ScheduledPaymentAutoCreateService {
  ScheduledPaymentAutoCreateService({
    required this.financeRepo,
    required this.transactionsRepo,
  });

  final FinanceRepoImpl financeRepo;
  final TransactionsRepository transactionsRepo;

  /// Проверяет и создаёт транзакции для платежей с nextDate == сегодня.
  Future<void> checkAndCreateForToday() async {
    try {
      final payments = await financeRepo.getScheduledPayments();
      final today = DateTime.now();
      final todayKey = today.dayKey;

      for (final payment in payments) {
        if (!payment.autoCreateTransaction || payment.isPaused) continue;

        final isIncome = payment.type == ScheduledPaymentType.regularIncome;
        final canCreate = isIncome
            ? (payment.walletId != null || payment.goalId != null)
            : (payment.walletId != null && payment.categoryId != null);
        if (!canCreate) continue;

        final nextDate = ScheduledPaymentDateService.computeNextDateForModel(payment);
        if (nextDate == null) continue;

        final nextDateKey = nextDate.dayKey;
        if (nextDateKey != todayKey) continue;

        final existing = await transactionsRepo.getUserTransactionsById(
          start: todayKey,
          end: todayKey,
          id: payment.id,
          idType: TransactionIdType.scheduledPayment,
        );
        if (existing.isNotEmpty) continue;

        final model = TransactionModel(
          id: '',
          categoryId: isIncome ? null : payment.categoryId,
          walletId: payment.walletId,
          goalId: payment.goalId,
          scheduledPaymentId: payment.id,
          dayKey: todayKey,
          periodKey: today.periodKey,
          amount: payment.amount,
          type: isIncome ? TransactionType.income : TransactionType.expense,
          createdAt: today,
          date: today,
        );
        await transactionsRepo.addTransaction(transaction: model);
      }
    } catch (_) {
      // Игнорируем ошибки при автосоздании
    }
  }
}
