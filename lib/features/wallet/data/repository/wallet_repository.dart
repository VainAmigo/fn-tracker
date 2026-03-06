import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/features.dart';

class WalletRepository implements WalletRepoImpl {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  String _requireUid() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('budget');

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('categories');

  @override
  Future<BudgetModel?> getBudget() async {
    final uid = _requireUid();
    try {
      final snapshot = await _budgetsRef(uid).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return BudgetModel.fromJson({...doc.data(), 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get budget: $e');
    }
  }

  @override
  Future<BudgetModel> createBudget({required BudgetModel budget}) async {
    final uid = _requireUid();
    try {
      final docRef = _budgetsRef(uid).doc();
      await docRef.set(
        BudgetModel(id: docRef.id, amount: budget.amount).toJson(),
      );
      return BudgetModel(id: docRef.id, amount: budget.amount);
    } catch (e) {
      throw Exception('Failed to create budget: $e');
    }
  }

  @override
  Future<BudgetModel> updateBudget({required BudgetModel budget}) async {
    final uid = _requireUid();
    try {
      final docRef = _budgetsRef(uid).doc(budget.id);
      await docRef.update(budget.toJson());
      return budget;
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    final uid = _requireUid();
    try {
      await _budgetsRef(uid).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  @override
  Future<BudgetStatModel> getBudgetStats({
    required DateTime start,
    required DateTime end,
  }) async {
    final uid = _requireUid();
    try {
      final results = await Future.wait([
        _budgetsRef(uid).get(),
        _transactionsRef(uid)
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
            .orderBy('createdAt', descending: true)
            .get(),
        _categoriesRef(uid).orderBy('createdAt', descending: true).get(),
      ]);

      final budgetSnapshot = results[0];
      final transactionsSnapshot = results[1];
      final categoriesSnapshot = results[2];

      final BudgetModel? budget = budgetSnapshot.docs.isEmpty
          ? null
          : BudgetModel.fromJson({
              ...budgetSnapshot.docs.first.data(),
              'id': budgetSnapshot.docs.first.id,
            });

      final expenseType = TransactionType.expense.toJson();

      final transactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .where((t) => t.type == TransactionType.expense)
          .toList();

      final totalForPeriod = transactionsSnapshot.docs
          .where((doc) => doc.data()['type'] == expenseType)
          .fold<double>(0.0, (sum, doc) => sum + (doc.data()['amount'] as num).toDouble());

      final categories = categoriesSnapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();

      final Map<String, double> spendingByCategoryId = {};
      for (final t in transactions) {
        spendingByCategoryId.update(
          t.categoryId,
          (prev) => prev + t.amount,
          ifAbsent: () => t.amount,
        );
      }

      final categoriesMap = {for (final c in categories) c.categoryId: c};

      final categorySpending = spendingByCategoryId.entries
          .where((e) => categoriesMap.containsKey(e.key))
          .map((e) => CategorySpending(
                category: categoriesMap[e.key]!,
                amount: e.value,
              ))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      return BudgetStatModel(
        budget: budget,
        transactions: transactions,
        totalForPeriod: totalForPeriod,
        categorySpending: categorySpending,
      );
    } catch (e) {
      throw Exception('Failed to get budget stats: $e');
    }
  }
}
