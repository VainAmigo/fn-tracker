import 'package:fn_tracker/features/transactions/data/models/transaction_model.dart';

abstract class TransactionsRepository {
  Future<List<TransactionModel>> getUserTransactionsByPeriod({
    required String start,
    required String end,
  });

  Future<List<TransactionModel>> getUserTransactionsById({
    required String id,
    required TransactionIdType idType,
    required String start,
    required String end,
  });

  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  });

  Future<HomePageStatModel> getHomePageStats({
    required String startDayKey,
    required String endDayKey,
  });

  Future<void> deleteTransaction({required String id});

  Future<void> deleteTransactionsByWalletId(String walletId);

  Future<void> deleteTransactionsByGoalId(String goalId);
}
