import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/features.dart';

class TransactionsRepository implements TransactionsRepoImpl {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  String _requireUid() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('transactions');

  @override
  Future<List<TransactionModel>> getUserTransactionsByPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final uid = _requireUid();

      final transactionsSnapshot = await _transactionsRef(uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();

      return transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .where((t) => t.type == TransactionType.expense)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  }) async {
    final uid = _requireUid();
    try {
      final createdAt = Timestamp.now();
      final docRef = _transactionsRef(uid).doc();

      final model = TransactionModel(
        id: docRef.id,
        categoryId: transaction.categoryId,
        walletId: transaction.walletId,
        dayKey: transaction.dayKey,
        periodKey: transaction.periodKey,
        amount: transaction.amount,
        note: transaction.note,
        createdAt: createdAt.toDate(),
        type: transaction.type,
      );

      await docRef.set({
        'id': model.id,
        'categoryId': model.categoryId,
        'walletId': model.walletId,
        'dayKey': model.dayKey,
        'periodKey': model.periodKey,
        'amount': model.amount,
        'note': model.note,
        'createdAt': createdAt,
        'type': model.type.toJson(),
      });

      return model;
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<double> getTotalForPeriod(DateTime start, DateTime end) async {
    try {
      final uid = _requireUid();
      final snapshot = await _transactionsRef(uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final expenseType = TransactionType.expense.toJson();
      return snapshot.docs
          .where((doc) => doc.data()['type'] == expenseType)
          .fold<double>(0.0, (double sum, doc) {
            return sum + (doc.data()['amount'] as num).toDouble();
          });
    } catch (e) {
      throw Exception('Failed to get total for period: $e');
    }
  }

  @override
  Future<HomePageStatModel> getHomePageStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    try {
      final uid = _requireUid();
      final snapshot = await _transactionsRef(uid)
          .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
          .where('dayKey', isLessThanOrEqualTo: endDayKey)
          .orderBy('dayKey', descending: true)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .where((t) => t.type == TransactionType.expense)
          .toList();

      final Map<String, double> perDay = {};
      for (final t in transactions) {
        perDay.update(
          t.dayKey,
          (prev) => prev + t.amount,
          ifAbsent: () => t.amount,
        );
      }

      final sortedDays = perDay.keys.toList()..sort();
      final dailyTotals = sortedDays
          .map((day) => perDay[day] ?? 0.0)
          .toList(growable: false);

      final totalExpense = dailyTotals.fold<double>(
        0.0,
        (double sum, v) => sum + v,
      );

      print('dailyTotals: $dailyTotals');

      return HomePageStatModel(
        totalExpense: totalExpense,
        homeChartStat: dailyTotals,
      );
    } catch (e) {
      throw Exception('Failed to get home page stats: $e');
    }
  }
}
