import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class AnalyticsRepository
    with FirestoreUserContext
    implements AnalyticsRepoImpl {
  @override
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      FirestorePaths.transactionsRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      FirestorePaths.categoriesRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) =>
      FirestorePaths.budgetRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) =>
      FirestorePaths.walletsRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) =>
      FirestorePaths.goalsRef(firebaseFirestore, uid);

  @override
  Future<AnalyticsPeriodModel> getAnalytics({
    required String startDayKey,
    required String endDayKey,
  }) async {
    final uid = requireUid();

    final results = await Future.wait([
      _transactionsRef(uid)
          .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
          .where('dayKey', isLessThanOrEqualTo: endDayKey)
          .get(),
      _categoriesRef(uid).orderBy('createdAt', descending: true).get(),
      _budgetsRef(uid).get(),
      _walletsRef(uid).get(),
      _goalsRef(uid).get(),
    ]);

    final transactionsSnapshot = results[0];
    final categoriesSnapshot = results[1];
    final budgetSnapshot = results[2];
    final walletsSnapshot = results[3];
    final goalsSnapshot = results[4];

    final hiddenWalletIds = walletsSnapshot.docs
        .where((d) => d.data()['isHidden'] == true)
        .map((d) => d.id)
        .toSet();
    final hiddenGoalIds = goalsSnapshot.docs
        .where((d) => d.data()['isHidden'] == true)
        .map((d) => d.id)
        .toSet();

    BudgetModel? budget;
    if (budgetSnapshot.docs.isNotEmpty) {
      final doc = budgetSnapshot.docs.first;
      budget = BudgetModel.fromJson({...doc.data(), 'id': doc.id});
    }

    final allTransactions = transactionsSnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .where((t) => t.transferId == null)
        .toList();

    final transactions = allTransactions.where((t) {
      if (t.walletId != null && hiddenWalletIds.contains(t.walletId)) {
        return false;
      }
      if (t.goalId != null && hiddenGoalIds.contains(t.goalId)) {
        return false;
      }
      return true;
    }).toList();

    final categories = categoriesSnapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data()))
        .toList();
    final categoriesMap = {for (final c in categories) c.categoryId: c};

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> spendingByCategoryId = {};
    final Map<String, ({double income, double expense})> byPeriod = {};
    final Map<int, Map<String, double>> spendingByWeekday = {};

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
        final weekday = t.date.weekday;
        spendingByWeekday
            .putIfAbsent(weekday, () => {})
            .update(
              t.categoryId ?? '',
              (prev) => prev + t.amount,
              ifAbsent: () => t.amount,
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

    final weeklySpending = List.generate(7, (i) {
      final weekday = i + 1;
      final byCategory = spendingByWeekday[weekday] ?? {};
      final dayCategorySpending =
          byCategory.entries
              .where((e) => categoriesMap.containsKey(e.key))
              .map(
                (e) => CategorySpending(
                  category: categoriesMap[e.key]!,
                  amount: e.value,
                ),
              )
              .toList()
            ..sort((a, b) => b.amount.compareTo(a.amount));
      return DailySpending(
        weekday: weekday,
        categorySpending: dayCategorySpending,
      );
    });

    return AnalyticsPeriodModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categorySpending: categorySpending,
      weeklySpending: weeklySpending,
      budget: budget,
    );
  }
}
