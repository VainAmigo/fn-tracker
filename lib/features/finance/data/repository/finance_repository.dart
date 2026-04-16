import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class FinanceRepository with FirestoreUserContext implements FinanceRepoImpl {
  FinanceRepository({TransactionsRepository? transactionsRepo})
    : _transactionsRepo = transactionsRepo ?? TransactionsRepositoryImpl();

  @override
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final TransactionsRepository _transactionsRepo;

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) =>
      FirestorePaths.budgetRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _budgetHistoryRef(
    String uid,
    String budgetId,
  ) =>
      FirestorePaths.budgetHistoryRef(firebaseFirestore, uid, budgetId);

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      FirestorePaths.transactionsRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      FirestorePaths.categoriesRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) =>
      FirestorePaths.walletsRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) =>
      FirestorePaths.goalsRef(firebaseFirestore, uid);

  CollectionReference<Map<String, dynamic>> _scheduledPaymentsRef(String uid) =>
      FirestorePaths.scheduledPaymentsRef(firebaseFirestore, uid);

  String _path(String uid, String sub) => 'users/$uid/$sub';

  @override
  Future<WalletModel> addWallet({required WalletModel wallet}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'addWallet',
      collection: _path(uid, 'wallets'),
      data: wallet.toJson(),
      fn: () async {
        final existing = await _walletsRef(uid).get();
        final isFirst = existing.docs.isEmpty;
        final docRef = _walletsRef(uid).doc();
        final created = wallet.copyWith(id: docRef.id, isDefault: isFirst);
        await docRef.set(created.toJson());
        return created;
      },
      serialize: (w) => w.toJson(),
    );
  }

  @override
  Future<WalletModel> updateWallet({required WalletModel wallet}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'updateWallet',
      collection: _path(uid, 'wallets'),
      docId: wallet.id,
      data: wallet.toJson(),
      fn: () async {
        if (wallet.isDefault) {
          await setDefaultWallet(wallet.id!);
        }
        final docRef = _walletsRef(uid).doc(wallet.id);
        await docRef.update(wallet.toJson());
        return wallet;
      },
      serialize: (w) => w.toJson(),
    );
  }

  @override
  Future<void> deleteWallet(
    String id, {
    required bool deleteTransactions,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'deleteWallet',
      collection: _path(uid, 'wallets'),
      docId: id,
      data: {'deleteTransactions': deleteTransactions},
      fn: () async {
        if (deleteTransactions) {
          await _transactionsRepo.deleteTransactionsByWalletId(id);
        }
        final walletDoc = await _walletsRef(uid).doc(id).get();
        final wasDefault = walletDoc.data()?['isDefault'] == true;
        await _walletsRef(uid).doc(id).delete();
        if (wasDefault) {
          final remaining = await _walletsRef(uid).limit(1).get();
          if (remaining.docs.isNotEmpty) {
            await remaining.docs.first.reference.update({'isDefault': true});
          }
        }
      },
    );
  }

  @override
  Future<void> setDefaultWallet(String walletId) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'setDefaultWallet',
      collection: _path(uid, 'wallets'),
      data: {'walletId': walletId},
      fn: () async {
        final snapshot = await _walletsRef(uid).get();
        final batch = firebaseFirestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'isDefault': doc.id == walletId});
        }
        await batch.commit();
      },
    );
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final uid = requireUid();
    return FirebaseLogger.query(
      operation: 'getWallets',
      collection: _path(uid, 'wallets'),
      filters: {'orderBy': 'isDefault DESC'},
      fn: () async {
        final results = await Future.wait([
          _walletsRef(uid).orderBy('isDefault', descending: true).get(),
          _transactionsRef(uid).get(),
        ]);
        final walletSnapshot = results[0];
        final transactionsSnapshot = results[1];
        final wallets = walletSnapshot.docs
            .map((doc) => WalletModel.fromJson(doc.data()))
            .toList();
        final transactions = transactionsSnapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList();
        final Map<String, double> balances = {};
        for (final t in transactions) {
          final current = balances[t.walletId] ?? 0;
          if (t.type == TransactionType.income) {
            balances[t.walletId ?? ''] = current + t.amount;
          } else {
            balances[t.walletId ?? ''] = current - t.amount;
          }
        }
        return wallets
            .map((w) => w.copyWith(balance: balances[w.id] ?? 0))
            .toList();
      },
      serialize: (wallets) => {
        '_docsCount': wallets.length,
        '_docs': wallets.map((w) => {
          'id': w.id,
          'name': w.name,
          'balance': w.balance,
          'isDefault': w.isDefault,
          'isHidden': w.isHidden,
        }).toList(),
      },
    );
  }

  @override
  Future<BudgetStatModel> getBudgetStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.query(
      operation: 'getBudgetStats',
      collection: _path(uid, 'budget + transactions + categories'),
      filters: {'dayKey >=': startDayKey, 'dayKey <=': endDayKey},
      fn: () async {
        final results = await Future.wait([
          _budgetsRef(uid).get(),
          _transactionsRef(uid)
              .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
              .where('dayKey', isLessThanOrEqualTo: endDayKey)
              .orderBy('dayKey', descending: true)
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
        final transactions = transactionsSnapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .where((t) => t.transferId == null)
            .where((t) => t.type == TransactionType.expense)
            .toList();
        final totalForPeriod = transactions.fold<double>(
          0.0,
          (double sum, t) => sum + t.amount,
        );
        final categories = categoriesSnapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data()))
            .toList();
        final Map<String, double> spendingByCategoryId = {};
        for (final t in transactions) {
          spendingByCategoryId.update(
            t.categoryId ?? '',
            (prev) => prev + t.amount,
            ifAbsent: () => t.amount,
          );
        }
        final categoriesMap = {for (final c in categories) c.categoryId: c};
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
        return BudgetStatModel(
          budget: budget,
          transactions: transactions,
          totalForPeriod: totalForPeriod,
          categorySpending: categorySpending,
        );
      },
      serialize: (s) => {
        'budgetAmount': s.budget?.amount,
        'totalForPeriod': s.totalForPeriod,
        'transactionsCount': s.transactions.length,
        'categoriesCount': s.categorySpending.length,
        '_docs': s.categorySpending.map((cs) => {
          'category': cs.category.name,
          'amount': cs.amount,
        }).toList(),
      },
    );
  }

  @override
  Future<BudgetModel> createBudget({required BudgetModel budget}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'createBudget',
      collection: _path(uid, 'budget'),
      data: {'amount': budget.amount},
      fn: () async {
        final docRef = _budgetsRef(uid).doc();
        final budgetId = docRef.id;
        final now = DateTime.now();
        final effectiveDayKey = now.dayKey;
        await docRef.set(
          BudgetModel(id: budgetId, amount: budget.amount).toJson(),
        );
        await _budgetHistoryRef(uid, budgetId).add({
          'amount': budget.amount,
          'effectiveDayKey': effectiveDayKey,
          'createdAt': now.toUtc().toIso8601String(),
        });
        return BudgetModel(id: budgetId, amount: budget.amount);
      },
      serialize: (b) => {'id': b.id, 'amount': b.amount},
    );
  }

  @override
  Future<BudgetModel> updateBudget({
    required BudgetModel budget,
    String? effectiveDayKey,
    bool replaceAll = false,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'updateBudget',
      collection: _path(uid, 'budget'),
      docId: budget.id,
      data: {
        'amount': budget.amount,
        'effectiveDayKey': effectiveDayKey,
        'replaceAll': replaceAll,
      },
      fn: () async {
        final docRef = _budgetsRef(uid).doc(budget.id);
        await docRef.update(budget.toJson());
        final now = DateTime.now();
        final historyRef = _budgetHistoryRef(uid, budget.id);

        if (replaceAll) {
          final snapshot = await historyRef.get();
          for (final doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }

        final key = effectiveDayKey ?? now.dayKey;
        await historyRef.add({
          'amount': budget.amount,
          'effectiveDayKey': key,
          'createdAt': now.toUtc().toIso8601String(),
        });
        return budget;
      },
      serialize: (b) => {'id': b.id, 'amount': b.amount},
    );
  }

  @override
  Future<List<BudgetHistoryEntry>> getBudgetHistory(String budgetId) async {
    final uid = requireUid();
    return FirebaseLogger.query(
      operation: 'getBudgetHistory',
      collection: _path(uid, 'budget/$budgetId/history'),
      filters: {'orderBy': 'effectiveDayKey'},
      fn: () async {
        final snapshot = await _budgetHistoryRef(uid, budgetId)
            .orderBy('effectiveDayKey')
            .get();
        return snapshot.docs
            .map((doc) => BudgetHistoryEntry.fromJson(doc.id, doc.data()))
            .toList();
      },
      serialize: (list) => {
        '_docsCount': list.length,
        '_docs': list.map((e) => {
          'id': e.id,
          'amount': e.amount,
          'effectiveDayKey': e.effectiveDayKey,
        }).toList(),
      },
    );
  }

  @override
  Future<void> addBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'addBudgetHistoryEntry',
      collection: _path(uid, 'budget/$budgetId/history'),
      data: entry.toJson(),
      fn: () => _budgetHistoryRef(uid, budgetId).add(entry.toJson()),
    );
  }

  @override
  Future<void> updateBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'updateBudgetHistoryEntry',
      collection: _path(uid, 'budget/$budgetId/history'),
      docId: entry.id,
      data: entry.toJson(),
      fn: () => _budgetHistoryRef(uid, budgetId)
          .doc(entry.id)
          .update(entry.toJson()),
    );
  }

  @override
  Future<void> deleteBudgetHistoryEntry({
    required String budgetId,
    required String entryId,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'deleteBudgetHistoryEntry',
      collection: _path(uid, 'budget/$budgetId/history'),
      docId: entryId,
      fn: () => _budgetHistoryRef(uid, budgetId).doc(entryId).delete(),
    );
  }

  @override
  Future<void> ensureBudgetHistoryIfEmpty({
    required String budgetId,
    required BudgetModel budget,
  }) async {
    final uid = requireUid();
    final snapshot = await _budgetHistoryRef(uid, budgetId).limit(1).get();
    if (snapshot.docs.isEmpty) {
      final now = DateTime.now();
      await _budgetHistoryRef(uid, budgetId).add({
        'amount': budget.amount,
        'effectiveDayKey': '2000-01-01',
        'createdAt': now.toUtc().toIso8601String(),
      });
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'deleteBudget',
      collection: _path(uid, 'budget'),
      docId: id,
      fn: () async {
        final historyRef = _budgetHistoryRef(uid, id);
        final snapshot = await historyRef.get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        await _budgetsRef(uid).doc(id).delete();
      },
    );
  }

  @override
  Future<GoalsModel> getGoals() async {
    final uid = requireUid();
    return FirebaseLogger.query(
      operation: 'getGoals',
      collection: _path(uid, 'goals + transactions'),
      fn: () async {
        final results = await Future.wait([
          _goalsRef(uid).get(),
          _transactionsRef(uid).where('goalId', isNull: false).get(),
        ]);
        final goalsSnapshot = results[0];
        final transactionsSnapshot = results[1];
        final Map<String, double> progressByGoalId = {};
        for (final doc in transactionsSnapshot.docs) {
          final t = TransactionModel.fromJson(doc.data());
          if (t.goalId == null || t.goalId!.isEmpty) continue;
          final delta = t.type == TransactionType.income ? t.amount : -t.amount;
          progressByGoalId.update(
            t.goalId!,
            (prev) => prev + delta,
            ifAbsent: () => delta,
          );
        }
        final goals = goalsSnapshot.docs.map((doc) {
          final goal = GoalModel.fromJson(doc.data());
          final progress = progressByGoalId[goal.id] ?? 0.0;
          return goal.copyWith(progress: progress);
        }).toList();
        final totalProgress = goals.fold<double>(0, (s, g) => s + g.progress);
        final totalTarget = goals.fold<double>(0, (s, g) => s + g.targetAmount);
        final completedCount = goals.where((g) => g.isCompleted).length;
        return GoalsModel(
          goals: goals,
          totalGoal: TotalGoalModel(
            totalProgress: totalProgress,
            totalTargetAmount: totalTarget,
            goalsCount: goals.length,
            completedCount: completedCount,
          ),
        );
      },
      serialize: (g) => {
        '_docsCount': g.goals.length,
        '_docs': g.goals.map((goal) => {
          'id': goal.id,
          'name': goal.name,
          'targetAmount': goal.targetAmount,
          'progress': goal.progress,
          'isCompleted': goal.isCompleted,
        }).toList(),
        'totalProgress': g.totalGoal.totalProgress,
        'totalTarget': g.totalGoal.totalTargetAmount,
      },
    );
  }

  @override
  Future<GoalModel> createGoal({required GoalModel goal}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'createGoal',
      collection: _path(uid, 'goals'),
      data: goal.toJson(),
      fn: () async {
        final docRef = _goalsRef(uid).doc();
        final created = goal.copyWith(id: docRef.id);
        await docRef.set(created.toJson());
        return created;
      },
      serialize: (g) => {'id': g.id, 'name': g.name},
    );
  }

  @override
  Future<GoalModel> updateGoal({required GoalModel goal}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'updateGoal',
      collection: _path(uid, 'goals'),
      docId: goal.id,
      data: goal.toJson(),
      fn: () async {
        final docRef = _goalsRef(uid).doc(goal.id);
        await docRef.update(goal.toJson());
        return goal;
      },
      serialize: (g) => {'id': g.id, 'name': g.name},
    );
  }

  @override
  Future<void> deleteGoal(String id, {required bool deleteTransactions}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'deleteGoal',
      collection: _path(uid, 'goals'),
      docId: id,
      data: {'deleteTransactions': deleteTransactions},
      fn: () async {
        if (deleteTransactions) {
          await _transactionsRepo.deleteTransactionsByGoalId(id);
        }
        await _goalsRef(uid).doc(id).delete();
      },
    );
  }

  @override
  Future<List<ScheduledPaymentModel>> getScheduledPayments() async {
    final uid = requireUid();
    return FirebaseLogger.query(
      operation: 'getScheduledPayments',
      collection: _path(uid, 'scheduled_payments'),
      fn: () async {
        final snapshot = await _scheduledPaymentsRef(uid).get();
        final models = <ScheduledPaymentModel>[];
        for (final doc in snapshot.docs) {
          final data = {...doc.data(), 'id': doc.id};
          final model = ScheduledPaymentModel.fromJson(data);
          final nextDate =
              ScheduledPaymentDateService.computeNextDateForModel(model);
          if (nextDate != null) {
            models.add(model.copyWith(nextDate: nextDate));
          } else if (model.frequency == ScheduledPaymentFrequency.oneTime) {
            continue;
          } else {
            models.add(model);
          }
        }
        models.sort(
          (a, b) =>
              (b.createdAt ?? b.nextDate).compareTo(a.createdAt ?? a.nextDate),
        );
        return models;
      },
      serialize: (list) => {
        '_docsCount': list.length,
        '_docs': list.map((p) => {
          'id': p.id,
          'amount': p.amount,
          'frequency': p.frequency.toJson(),
          'nextDate': p.nextDate.toIso8601String(),
        }).toList(),
      },
    );
  }

  @override
  Future<ScheduledPaymentModel> createScheduledPayment({
    required ScheduledPaymentModel payment,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'createScheduledPayment',
      collection: _path(uid, 'scheduled_payments'),
      data: {
        'amount': payment.amount,
        'frequency': payment.frequency.toJson(),
        'walletId': payment.walletId,
        'categoryId': payment.categoryId,
      },
      fn: () async {
        final docRef = _scheduledPaymentsRef(uid).doc();
        final now = DateTime.now();
        final nextDate = ScheduledPaymentDateService.calculateNextDate(
          frequency: payment.frequency,
          paymentDate: payment.paymentDate,
          monthDays: payment.monthDays,
          yearlyDates: payment.yearlyDates,
        );
        final created = payment.copyWith(
          id: docRef.id,
          nextDate: nextDate ?? payment.nextDate,
          createdAt: now,
          updatedAt: now,
        );
        await docRef.set(created.toJson());
        return created;
      },
      serialize: (p) => {
        'id': p.id,
        'amount': p.amount,
        'nextDate': p.nextDate.toIso8601String(),
      },
    );
  }

  @override
  Future<ScheduledPaymentModel> updateScheduledPayment({
    required ScheduledPaymentModel payment,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'updateScheduledPayment',
      collection: _path(uid, 'scheduled_payments'),
      docId: payment.id,
      data: {
        'amount': payment.amount,
        'frequency': payment.frequency.toJson(),
      },
      fn: () async {
        final nextDate = ScheduledPaymentDateService.calculateNextDate(
          frequency: payment.frequency,
          paymentDate: payment.paymentDate,
          monthDays: payment.monthDays,
          yearlyDates: payment.yearlyDates,
        );
        final updated = payment.copyWith(
          nextDate: nextDate ?? payment.nextDate,
          updatedAt: DateTime.now(),
        );
        await _scheduledPaymentsRef(uid).doc(payment.id).update(updated.toJson());
        return updated;
      },
      serialize: (p) => {
        'id': p.id,
        'nextDate': p.nextDate.toIso8601String(),
      },
    );
  }

  @override
  Future<void> deleteScheduledPayment(String id) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'deleteScheduledPayment',
      collection: _path(uid, 'scheduled_payments'),
      docId: id,
      fn: () => _scheduledPaymentsRef(uid).doc(id).delete(),
    );
  }
}
