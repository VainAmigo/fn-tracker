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
  Future<List<TransactionModel>> getUserTransactions() async {
    try {
      final uid = _requireUid();

      final transactionsSnapshot = await _transactionsRef(uid)
          .where('type', isEqualTo: TransactionType.expense.toJson())
          .orderBy('createdAt', descending: true)
          .get();

      return transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
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
      final createdAt = Timestamp.fromDate(transaction.createdAt);
      final docRef = _transactionsRef(uid).doc();

      final model = TransactionModel(
        id: docRef.id,
        categoryId: transaction.categoryId,
        amount: transaction.amount,
        note: transaction.note,
        createdAt: createdAt.toDate(),
        currency: transaction.currency,
        type: transaction.type,
      );

      await docRef.set({
        'id': model.id,
        'categoryId': model.categoryId,
        'amount': model.amount,
        'note': model.note,
        'createdAt': createdAt,
        'currency': model.currency,
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
          .where('type', isEqualTo: TransactionType.expense.toJson())
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs.fold<double>(0.0, (double sum, doc) {
        return sum + (doc.data()['amount'] as num).toDouble();
      });
    } catch (e) {
      throw Exception('Failed to get total for period: $e');
    }
  }

  @override
  Future<HomePageStatModel> getHomePageStats() async {
    try {
      final uid = _requireUid();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfNextMonth = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);

      final snapshot = await _transactionsRef(uid)
          .where('type', isEqualTo: TransactionType.expense.toJson())
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'createdAt',
            isLessThan: Timestamp.fromDate(startOfNextMonth),
          )
          .orderBy('createdAt', descending: true)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();

      // Суммируем только по тем дням, где есть транзакции
      final Map<int, double> perDay = {};
      for (final t in transactions) {
        final d = t.createdAt;
        if (d.year == now.year && d.month == now.month) {
          perDay.update(
            d.day,
            (prev) => prev + t.amount,
            ifAbsent: () => t.amount,
          );
        }
      }

      // Сортируем дни и возвращаем только суммы за дни с записями
      final sortedDays = perDay.keys.toList()..sort();
      final dailyTotals =
          sortedDays.map((day) => perDay[day] ?? 0.0).toList(growable: false);

      final totalExpense =
          dailyTotals.fold<double>(0.0, (double sum, v) => sum + v);

      return HomePageStatModel(
        totalExpense: totalExpense,
        homeChartStat: dailyTotals,
      );
    } catch (e) {
      throw Exception('Failed to get home page stats: $e');
    }
  }
}
