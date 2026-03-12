import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/features.dart';

class AnalyticsRepository implements AnalyticsRepoImpl {
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

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('categories');

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('budget');

  @override
  Future<AnalyticsPeriodModel> getAnalytics({
    required String startDayKey,
    required String endDayKey,
    required List<String> periodKeysForTrend,
  }) async {
    final uid = _requireUid();

    final results = await Future.wait([
      _transactionsRef(uid)
          .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
          .where('dayKey', isLessThanOrEqualTo: endDayKey)
          .get(),
      _categoriesRef(uid).orderBy('createdAt', descending: true).get(),
      _budgetsRef(uid).get(),
    ]);

    final transactionsSnapshot = results[0];
    final categoriesSnapshot = results[1];
    final budgetSnapshot = results[2];

    BudgetModel? budget;
    if (budgetSnapshot.docs.isNotEmpty) {
      final doc = budgetSnapshot.docs.first;
      budget = BudgetModel.fromJson({...doc.data(), 'id': doc.id});
    }

    final transactions = transactionsSnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .where((t) => t.transferId == null)
        .toList();

    final categories = categoriesSnapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data()))
        .toList();
    final categoriesMap = {for (final c in categories) c.categoryId: c};

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> spendingByCategoryId = {};
    final Map<String, ({double income, double expense})> byPeriod = {};

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
        byPeriod.update(
          t.periodKey,
          (v) => (income: v.income + t.amount, expense: v.expense),
          ifAbsent: () => (income: t.amount, expense: 0),
        );
      } else {
        totalExpense += t.amount;
        spendingByCategoryId.update(
          t.categoryId ?? '',
          (prev) => prev + t.amount,
          ifAbsent: () => t.amount,
        );
        byPeriod.update(
          t.periodKey,
          (v) => (income: v.income, expense: v.expense + t.amount),
          ifAbsent: () => (income: 0, expense: t.amount),
        );
      }
    }

    final categorySpending =
        spendingByCategoryId.entries
            .where((e) => categoriesMap.containsKey(e.key))
            .map(
              (e) => CategorySpending(
                category: categoriesMap[e.key]!,
                amount: e.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final monthlyTrend = periodKeysForTrend
        .map(
          (pk) => MonthlyTrendItem(
            periodKey: pk,
            income: byPeriod[pk]?.income ?? 0,
            expense: byPeriod[pk]?.expense ?? 0,
          ),
        )
        .toList();

    return AnalyticsPeriodModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categorySpending: categorySpending,
      monthlyTrend: monthlyTrend,
      budget: budget,
    );
  }
}
