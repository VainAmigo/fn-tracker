import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';

/// Удаляет все подколлекции `users/{uid}/…` (транзакции, кошельки и т.д.).
final class UserFirestoreCleanup {
  UserFirestoreCleanup(this._firestore);

  final FirebaseFirestore _firestore;

  static const int _batchSize = 400;

  Future<void> wipeAllSubcollections(String uid) async {
    await _deleteCollection(FirestorePaths.transactionsRef(_firestore, uid));
    await _deleteCollection(FirestorePaths.categoriesRef(_firestore, uid));
    await _deleteCollection(FirestorePaths.walletsRef(_firestore, uid));
    await _deleteCollection(FirestorePaths.goalsRef(_firestore, uid));
    await _deleteCollection(
      FirestorePaths.scheduledPaymentsRef(_firestore, uid),
    );
    await _wipeBudgetCollections(uid);
    await _deleteCollection(FirestorePaths.settingsRef(_firestore, uid));
  }

  Future<void> _wipeBudgetCollections(String uid) async {
    final budgetCol = FirestorePaths.budgetRef(_firestore, uid);
    final budgets = await budgetCol.get();
    for (final doc in budgets.docs) {
      await _deleteCollection(doc.reference.collection('history'));
      await doc.reference.delete();
    }
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snap = await collection.limit(_batchSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < _batchSize) break;
    }
  }
}
