import 'package:fn_tracker/features/transactions/data/models/transaction_model.dart';

abstract class TransactionsRepoImpl {
  Future<List<TransactionModel>> getUserTransactionsByPeriod({
    required DateTime start,
    required DateTime end,
  });

  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  });

  Future<double> getTotalForPeriod(DateTime start, DateTime end);

  Future<HomePageStatModel> getHomePageStats({
    required String startDayKey,
    required String endDayKey,
  });
}
