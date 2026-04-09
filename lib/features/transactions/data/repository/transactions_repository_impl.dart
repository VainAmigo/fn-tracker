import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class TransactionsRepositoryImpl
    with FirestoreUserContext
    implements TransactionsRepository {
  @override
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      FirestorePaths.transactionsRef(firebaseFirestore, uid);

  @override
  Future<List<TransactionModel>> getUserTransactionsByPeriod({
    required String start,
    required String end,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<List<TransactionModel>>(
      'Firestore.getUserTransactionsByPeriod',
      {'start': start, 'end': end},
      () async {
        final snapshot = await _transactionsRef(uid)
            .where('dayKey', isGreaterThanOrEqualTo: start)
            .where('dayKey', isLessThanOrEqualTo: end)
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList();
      },
      serializeResponse: (t) => {'count': t.length},
    ).catchError((e) => throw Exception('Failed to fetch transactions: $e'));
  }

  @override
  Future<List<TransactionModel>> getUserTransactionsById({
    required String start,
    required String end,
    required String id,
    required TransactionIdType idType,
  }) async {
    final uid = requireUid();
    final idFieldName = switch (idType) {
      TransactionIdType.category => 'categoryId',
      TransactionIdType.wallet => 'walletId',
      TransactionIdType.goal => 'goalId',
      TransactionIdType.scheduledPayment => 'scheduledPaymentId',
    };
    return FirebaseLogger.withLogging<List<TransactionModel>>(
      'Firestore.getUserTransactionsById',
      {'id': id, 'idType': idType.name, 'start': start, 'end': end},
      () async {
        final snapshot = await _transactionsRef(uid)
            .where(idFieldName, isEqualTo: id)
            .where('dayKey', isGreaterThanOrEqualTo: start)
            .where('dayKey', isLessThanOrEqualTo: end)
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList();
      },
      serializeResponse: (t) => {'count': t.length},
    ).catchError((e) => throw Exception('Failed to fetch transaction: $e'));
  }

  @override
  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<TransactionModel>(
      'Firestore.addTransaction',
      {
        'amount': transaction.amount,
        'type': transaction.type.toJson(),
        'dayKey': transaction.dayKey,
      },
      () async {
        final createdAt = Timestamp.now();
        final docRef = _transactionsRef(uid).doc();
        final model = TransactionModel(
          id: docRef.id,
          categoryId: transaction.categoryId,
          walletId: transaction.walletId,
          goalId: transaction.goalId,
          scheduledPaymentId: transaction.scheduledPaymentId,
          dayKey: transaction.dayKey,
          periodKey: transaction.periodKey,
          amount: transaction.amount,
          currency: transaction.currency,
          note: transaction.note,
          createdAt: createdAt.toDate(),
          date: transaction.date,
          type: transaction.type,
          transferId: transaction.transferId,
        );
        await docRef.set({
          'id': model.id,
          'categoryId': model.categoryId,
          'walletId': model.walletId,
          'goalId': model.goalId,
          'scheduledPaymentId': model.scheduledPaymentId,
          'dayKey': model.dayKey,
          'periodKey': model.periodKey,
          'amount': model.amount,
          'currency': model.currency,
          'note': model.note,
          'createdAt': createdAt,
          'date': model.date,
          'type': model.type.toJson(),
          'transferId': model.transferId,
        });
        return model;
      },
      serializeResponse: (m) => {'id': m.id, 'amount': m.amount},
    ).catchError((e) => throw Exception('Failed to add transaction: $e'));
  }

  @override
  Future<void> deleteTransaction({required String id}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteTransaction',
      {'id': id},
      () => _transactionsRef(uid).doc(id).delete(),
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to delete transaction: $e'));
  }

  @override
  Future<void> deleteTransactionsByWalletId(String walletId) async {
    if (walletId.isEmpty) return;
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteTransactionsByWalletId',
      {'walletId': walletId},
      () async {
        final allSnapshot = await _transactionsRef(uid).get();
        final toDelete = <DocumentReference<Map<String, dynamic>>>[];
        final transferIdsToFind = <String>{};
        for (final doc in allSnapshot.docs) {
          final data = doc.data();
          final docWalletId = data['walletId'] as String?;
          if (docWalletId == walletId) {
            toDelete.add(doc.reference);
            final tid = data['transferId'] as String?;
            if (tid != null && tid.isNotEmpty) transferIdsToFind.add(tid);
          }
        }
        for (final doc in allSnapshot.docs) {
          final tid = doc.data()['transferId'] as String?;
          if (tid != null &&
              transferIdsToFind.contains(tid) &&
              !toDelete.any((r) => r.id == doc.id)) {
            toDelete.add(doc.reference);
          }
        }
        for (var i = 0; i < toDelete.length; i += 450) {
          final batch = firebaseFirestore.batch();
          final end = (i + 450).clamp(0, toDelete.length);
          for (var j = i; j < end; j++) {
            batch.delete(toDelete[j]);
          }
          await batch.commit();
        }
      },
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) =>
        throw Exception('Failed to delete transactions by wallet: $e'));
  }

  @override
  Future<void> deleteTransactionsByGoalId(String goalId) async {
    if (goalId.isEmpty) return;
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteTransactionsByGoalId',
      {'goalId': goalId},
      () async {
        final allSnapshot = await _transactionsRef(uid).get();
        final toDelete = <DocumentReference<Map<String, dynamic>>>[];
        final transferIdsToFind = <String>{};
        for (final doc in allSnapshot.docs) {
          final data = doc.data();
          final docGoalId = data['goalId'] as String?;
          if (docGoalId == goalId) {
            toDelete.add(doc.reference);
            final tid = data['transferId'] as String?;
            if (tid != null && tid.isNotEmpty) transferIdsToFind.add(tid);
          }
        }
        for (final doc in allSnapshot.docs) {
          final tid = doc.data()['transferId'] as String?;
          if (tid != null &&
              transferIdsToFind.contains(tid) &&
              !toDelete.any((r) => r.id == doc.id)) {
            toDelete.add(doc.reference);
          }
        }
        for (var i = 0; i < toDelete.length; i += 450) {
          final batch = firebaseFirestore.batch();
          final end = (i + 450).clamp(0, toDelete.length);
          for (var j = i; j < end; j++) {
            batch.delete(toDelete[j]);
          }
          await batch.commit();
        }
      },
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) =>
        throw Exception('Failed to delete transactions by goal: $e'));
  }

  @override
  Future<void> deleteTransactionsByCategoryId(String categoryId) async {
    if (categoryId.isEmpty) return;
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteTransactionsByCategoryId',
      {'categoryId': categoryId},
      () async {
        final allSnapshot = await _transactionsRef(uid).get();
        final toDelete = <DocumentReference<Map<String, dynamic>>>[];
        for (final doc in allSnapshot.docs) {
          if (doc.data()['categoryId'] == categoryId) {
            toDelete.add(doc.reference);
          }
        }
        for (var i = 0; i < toDelete.length; i += 450) {
          final batch = firebaseFirestore.batch();
          final end = (i + 450).clamp(0, toDelete.length);
          for (var j = i; j < end; j++) {
            batch.delete(toDelete[j]);
          }
          await batch.commit();
        }
      },
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) =>
        throw Exception('Failed to delete transactions by category: $e'));
  }

  @override
  Future<HomePageStatModel> getHomePageStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<HomePageStatModel>(
      'Firestore.getHomePageStats',
      {'startDayKey': startDayKey, 'endDayKey': endDayKey},
      () async {
        final snapshot = await _transactionsRef(uid)
            .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
            .where('dayKey', isLessThanOrEqualTo: endDayKey)
            .orderBy('dayKey', descending: true)
            .get();
        final transactions = snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .where((t) => t.transferId == null)
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
      },
      serializeResponse: (s) => {
        'totalExpense': s.totalExpense,
        'daysCount': s.homeChartStat.length,
      },
    ).catchError((e) => throw Exception('Failed to get home page stats: $e'));
  }
}
