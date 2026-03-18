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

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) =>
      FirestorePaths.walletsRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) =>
      FirestorePaths.goalsRef(firebaseFirestore, uid);

  @override
  Future<AnalyticsModel> getAnalytics({
    required String startDayKey,
    required String endDayKey,
    required DatePickerPeriod period,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<AnalyticsModel>(
      'Firestore.getAnalytics',
      {'startDayKey': startDayKey, 'endDayKey': endDayKey},
      () async {
        final results = await Future.wait([
          _transactionsRef(uid)
              .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
              .where('dayKey', isLessThanOrEqualTo: endDayKey)
              .get(),
          _categoriesRef(uid).orderBy('createdAt', descending: true).get(),
          _walletsRef(uid).get(),
          _goalsRef(uid).get(),
        ]);

        final transactionsSnapshot = results[0];
        final categoriesSnapshot = results[1];
        final walletsSnapshot = results[2];
        final goalsSnapshot = results[3];

        final hiddenWalletIds = walletsSnapshot.docs
            .where((d) => d.data()['isHidden'] == true)
            .map((d) => d.id)
            .toSet();
        final hiddenGoalIds = goalsSnapshot.docs
            .where((d) => d.data()['isHidden'] == true)
            .map((d) => d.id)
            .toSet();

        final transactions = transactionsSnapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .where((t) => t.transferId == null)
            .where((t) {
              if (t.walletId != null && hiddenWalletIds.contains(t.walletId)) {
                return false;
              }
              if (t.goalId != null && hiddenGoalIds.contains(t.goalId)) {
                return false;
              }
              return true;
            })
            .toList();

        final categories = categoriesSnapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data()))
            .toList();
        final categoriesMap = {for (final c in categories) c.categoryId: c};

        double totalIncome = 0;
        double totalExpense = 0;
        final Map<String, double> spendingByCategoryId = {};
        final Map<int, Map<String, double>> spendingByDay = {};
        final Map<int, Map<String, double>> spendingByMonth = {};
        final Map<int, Map<String, double>> spendingByWeekday = {};

        for (final t in transactions) {
          if (t.type == TransactionType.income) {
            totalIncome += t.amount;
          } else {
            totalExpense += t.amount;
            spendingByCategoryId.update(
              t.categoryId ?? '',
              (prev) => prev + t.amount,
              ifAbsent: () => t.amount,
            );
            spendingByDay
                .putIfAbsent(t.date.day, () => {})
                .update(
                  t.categoryId ?? '',
                  (prev) => prev + t.amount,
                  ifAbsent: () => t.amount,
                );
            spendingByMonth
                .putIfAbsent(t.date.month, () => {})
                .update(
                  t.categoryId ?? '',
                  (prev) => prev + t.amount,
                  ifAbsent: () => t.amount,
                );
            spendingByWeekday
                .putIfAbsent(t.date.weekday, () => {})
                .update(
                  t.categoryId ?? '',
                  (prev) => prev + t.amount,
                  ifAbsent: () => t.amount,
                );
          }
        }

        final categorySpending = spendingByCategoryId.entries
            .where((e) => categoriesMap.containsKey(e.key))
            .map(
              (e) => CategorySpending(
                category: categoriesMap[e.key]!,
                amount: e.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

        final now = DateTime.now();
        final periodSegments = switch (period) {
          YearlyPeriod() => _buildPeriodSegments(
              count: 12,
              categoriesMap: categoriesMap,
              spendingMap: spendingByMonth,
              labels: ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'],
              isInitialVisible: (i) => (i + 1) == now.month,
            ),
          MonthlyPeriod(:final year, :final month) => () {
              final daysInMonth = DateTime(year, month.value + 1, 0).day;
              return _buildPeriodSegments(
                count: daysInMonth,
                categoriesMap: categoriesMap,
                spendingMap: spendingByDay,
                labels: List.generate(daysInMonth, (i) => '${i + 1}'),
                isInitialVisible: (i) => (i + 1) == now.day,
              );
            }(),
          WeeklyPeriod() => _buildPeriodSegments(
              count: 7,
              categoriesMap: categoriesMap,
              spendingMap: spendingByWeekday,
              labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
              isInitialVisible: (i) => (i + 1) == now.weekday,
            ),
        };

        return AnalyticsModel(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          categorySpending: categorySpending,
          periodSegments: periodSegments,
        );
      },
      serializeResponse: (a) => {
        'totalIncome': a.totalIncome,
        'totalExpense': a.totalExpense,
      },
    );
  }

  List<PeriodSegmentItem> _buildPeriodSegments({
    required int count,
    required Map<String, CategoryModel> categoriesMap,
    required Map<int, Map<String, double>> spendingMap,
    required List<String> labels,
    required bool Function(int index) isInitialVisible,
  }) {
    return List.generate(count, (i) {
      final key = i + 1;
      final byCategory = spendingMap[key] ?? {};
      final categorySpending = byCategory.entries
          .where((e) => categoriesMap.containsKey(e.key))
          .map(
            (e) => CategorySpending(
              category: categoriesMap[e.key]!,
              amount: e.value,
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
      return PeriodSegmentItem(
        label: labels[i],
        categorySpending: categorySpending,
        isInitialVisible: isInitialVisible(i),
      );
    });
  }
}
