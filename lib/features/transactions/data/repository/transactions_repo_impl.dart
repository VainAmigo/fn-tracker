import 'package:fn_tracker/features/transactions/data/models/transaction_model.dart';

abstract class TransactionsRepoImpl {
  Future<List<TransactionModel>> getUserTransactions();

  Future<TransactionModel> addTransaction({required TransactionModel transaction});

  Future<double> getTotalForPeriod(DateTime start, DateTime end);
}