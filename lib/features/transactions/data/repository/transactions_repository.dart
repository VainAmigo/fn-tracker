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
    required String start,
    required String end,
  }) async {
    try {
      final uid = _requireUid();

      final transactionsSnapshot = await _transactionsRef(uid)
          .where('dayKey', isGreaterThanOrEqualTo: start)
          .where('dayKey', isLessThanOrEqualTo: end)
          .orderBy('dayKey', descending: true)
          .get();

      return transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getUserTransactionsById({
    required String start,
    required String end,
    required String id,
    required TransactionIdType idType,
  }) async {
    final uid = _requireUid();
    final idFieldName = switch (idType) {
      TransactionIdType.category => 'categoryId',
      TransactionIdType.wallet => 'walletId',
      TransactionIdType.goal => 'goalId',
    };
    try {
      final transactionsSnapshot = await _transactionsRef(uid)
          .where(idFieldName, isEqualTo: id)
          .where('dayKey', isGreaterThanOrEqualTo: start)
          .where('dayKey', isLessThanOrEqualTo: end)
          .orderBy('dayKey', descending: true)
          .get();

      return transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transaction: $e');
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
        goalId: transaction.goalId,
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
        'goalId': model.goalId,
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
  Future<void> deleteTransaction({required String id}) async {
    final uid = _requireUid();
    try {
      await _transactionsRef(uid).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
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

      return HomePageStatModel(
        totalExpense: totalExpense,
        homeChartStat: dailyTotals,
      );
    } catch (e) {
      throw Exception('Failed to get home page stats: $e');
    }
  }
}
