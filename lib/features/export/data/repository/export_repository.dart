import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class ExportRepository with FirestoreUserContext implements ExportRepoImpl {
  @override
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      FirestorePaths.transactionsRef(firebaseFirestore, uid);
  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      FirestorePaths.categoriesRef(firebaseFirestore, uid);
  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) =>
      FirestorePaths.walletsRef(firebaseFirestore, uid);
  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) =>
      FirestorePaths.goalsRef(firebaseFirestore, uid);

  @override
  Future<List<ExportItem>> getTransactionsForExport({
    required String startDayKey,
    required String endDayKey,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<List<ExportItem>>(
      'Firestore.getTransactionsForExport',
      {'startDayKey': startDayKey, 'endDayKey': endDayKey},
      () async {
        final results = await Future.wait([
          _transactionsRef(uid)
              .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
              .where('dayKey', isLessThanOrEqualTo: endDayKey)
              .orderBy('createdAt', descending: true)
              .get(),
          _categoriesRef(uid).get(),
          _walletsRef(uid).get(),
          _goalsRef(uid).get(),
        ]);

        final transactionsSnapshot = results[0];
        final categoriesSnapshot = results[1];
        final walletsSnapshot = results[2];
        final goalsSnapshot = results[3];

        final categoriesById = {
          for (final doc in categoriesSnapshot.docs)
            doc.id: CategoryModel.fromJson(doc.data()),
        };
        final walletsById = {
          for (final doc in walletsSnapshot.docs)
            doc.id: WalletModel.fromJson(doc.data()),
        };
        final goalsById = {
          for (final doc in goalsSnapshot.docs)
            doc.id: GoalModel.fromJson(doc.data()),
        };

        final hiddenWalletIds = walletsById.values
            .where((wallet) => wallet.isHidden)
            .map((wallet) => wallet.id)
            .toSet();
        final hiddenGoalIds = goalsById.values
            .where((goal) => goal.isHidden)
            .map((goal) => goal.id)
            .toSet();

        return transactionsSnapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .where((t) => t.transferId == null)
            .where(
              (t) =>
                  t.walletId == null || !hiddenWalletIds.contains(t.walletId),
            )
            .where((t) => t.goalId == null || !hiddenGoalIds.contains(t.goalId))
            .map(
              (t) => ExportItem(
                transactionId: t.id,
                date: t.date,
                createdAt: t.createdAt,
                type: t.type,
                amount: t.amount,
                currency: t.currency,
                note: t.note,
                categoryName: t.categoryId == null
                    ? null
                    : categoriesById[t.categoryId!]?.name,
                walletName: t.walletId == null
                    ? null
                    : walletsById[t.walletId!]?.name,
                goalName: t.goalId == null ? null : goalsById[t.goalId!]?.name,
                dayKey: t.dayKey,
                periodKey: t.periodKey,
              ),
            )
            .toList();
      },
      serializeResponse: (list) => {'count': list.length},
    );
  }
}
