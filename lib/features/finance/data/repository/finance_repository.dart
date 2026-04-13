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

  @override
  Future<WalletModel> addWallet({required WalletModel wallet}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<WalletModel>(
      'Firestore.addWallet',
      {'name': wallet.name},
      () async {
        final existing = await _walletsRef(uid).get();
        final isFirst = existing.docs.isEmpty;
        final docRef = _walletsRef(uid).doc();
        final created = wallet.copyWith(id: docRef.id, isDefault: isFirst);
        await docRef.set(created.toJson());
        return created;
      },
      serializeResponse: (w) => {'id': w.id, 'name': w.name},
    ).catchError((e) => throw Exception('Failed to add wallet: $e'));
  }

  @override
  Future<WalletModel> updateWallet({required WalletModel wallet}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<WalletModel>(
      'Firestore.updateWallet',
      {'id': wallet.id, 'name': wallet.name},
      () async {
        if (wallet.isDefault) {
          await setDefaultWallet(wallet.id!);
        }
        final docRef = _walletsRef(uid).doc(wallet.id);
        await docRef.update(wallet.toJson());
        return wallet;
      },
      serializeResponse: (w) => {'id': w.id},
    ).catchError((e) => throw Exception('Failed to update wallet: $e'));
  }

  @override
  Future<void> deleteWallet(
    String id, {
    required bool deleteTransactions,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteWallet',
      {'id': id, 'deleteTransactions': deleteTransactions},
      () async {
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
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to delete wallet: $e'));
  }

  @override
  Future<void> setDefaultWallet(String walletId) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.setDefaultWallet',
      {'walletId': walletId},
      () async {
        final snapshot = await _walletsRef(uid).get();
        final batch = firebaseFirestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'isDefault': doc.id == walletId});
        }
        await batch.commit();
      },
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to set default wallet: $e'));
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<List<WalletModel>>(
      'Firestore.getWallets',
      {},
      () async {
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
      serializeResponse: (w) => {'count': w.length},
    ).catchError((e) => throw Exception('Failed to get wallets: $e'));
  }

  @override
  Future<BudgetStatModel> getBudgetStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<BudgetStatModel>(
      'Firestore.getBudgetStats',
      {'startDayKey': startDayKey, 'endDayKey': endDayKey},
      () async {
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
      serializeResponse: (s) => {
        'transactionsCount': s.transactions.length,
        'totalForPeriod': s.totalForPeriod,
      },
    ).catchError((e) => throw Exception('Failed to get budget stats: $e'));
  }

  @override
  Future<BudgetModel> createBudget({required BudgetModel budget}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<BudgetModel>(
      'Firestore.createBudget',
      {'amount': budget.amount},
      () async {
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
      serializeResponse: (b) => {'id': b.id, 'amount': b.amount},
    ).catchError((e) => throw Exception('Failed to create budget: $e'));
  }

  @override
  Future<BudgetModel> updateBudget({
    required BudgetModel budget,
    String? effectiveDayKey,
    bool replaceAll = false,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<BudgetModel>(
      'Firestore.updateBudget',
      {
        'id': budget.id,
        'amount': budget.amount,
        'effectiveDayKey': effectiveDayKey,
        'replaceAll': replaceAll,
      },
      () async {
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
      serializeResponse: (b) => {'id': b.id},
    ).catchError((e) => throw Exception('Failed to update budget: $e'));
  }

  @override
  Future<List<BudgetHistoryEntry>> getBudgetHistory(String budgetId) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<List<BudgetHistoryEntry>>(
      'Firestore.getBudgetHistory',
      {'budgetId': budgetId},
      () async {
        final snapshot = await _budgetHistoryRef(uid, budgetId)
            .orderBy('effectiveDayKey')
            .get();
        return snapshot.docs
            .map((doc) => BudgetHistoryEntry.fromJson(doc.id, doc.data()))
            .toList();
      },
      serializeResponse: (h) => {'count': h.length},
    ).catchError((e) => throw Exception('Failed to get budget history: $e'));
  }

  @override
  Future<void> addBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.addBudgetHistoryEntry',
      {'budgetId': budgetId, 'amount': entry.amount},
      () => _budgetHistoryRef(uid, budgetId).add(entry.toJson()),
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to add budget history: $e'));
  }

  @override
  Future<void> updateBudgetHistoryEntry({
    required String budgetId,
    required BudgetHistoryEntry entry,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.updateBudgetHistoryEntry',
      {'budgetId': budgetId, 'entryId': entry.id},
      () => _budgetHistoryRef(uid, budgetId)
          .doc(entry.id)
          .update(entry.toJson()),
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to update budget history: $e'));
  }

  @override
  Future<void> deleteBudgetHistoryEntry({
    required String budgetId,
    required String entryId,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteBudgetHistoryEntry',
      {'budgetId': budgetId, 'entryId': entryId},
      () => _budgetHistoryRef(uid, budgetId).doc(entryId).delete(),
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to delete budget history: $e'));
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
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteBudget',
      {'id': id},
      () async {
        final historyRef = _budgetHistoryRef(uid, id);
        final snapshot = await historyRef.get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        await _budgetsRef(uid).doc(id).delete();
      },
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to delete budget: $e'));
  }

  @override
  Future<GoalsModel> getGoals() async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<GoalsModel>(
      'Firestore.getGoals',
      {},
      () async {
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
      serializeResponse: (g) => {'goalsCount': g.goals.length},
    ).catchError((e) => throw Exception('Failed to get goals: $e'));
  }

  @override
  Future<GoalModel> createGoal({required GoalModel goal}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<GoalModel>(
      'Firestore.createGoal',
      {'name': goal.name, 'targetAmount': goal.targetAmount},
      () async {
        final docRef = _goalsRef(uid).doc();
        final created = goal.copyWith(id: docRef.id);
        await docRef.set(created.toJson());
        return created;
      },
      serializeResponse: (g) => {'id': g.id, 'name': g.name},
    ).catchError((e) => throw Exception('Failed to create goal: $e'));
  }

  @override
  Future<GoalModel> updateGoal({required GoalModel goal}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<GoalModel>(
      'Firestore.updateGoal',
      {'id': goal.id, 'name': goal.name},
      () async {
        final docRef = _goalsRef(uid).doc(goal.id);
        await docRef.update(goal.toJson());
        return goal;
      },
      serializeResponse: (g) => {'id': g.id},
    ).catchError((e) => throw Exception('Failed to update goal: $e'));
  }

  @override
  Future<void> deleteGoal(String id, {required bool deleteTransactions}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteGoal',
      {'id': id, 'deleteTransactions': deleteTransactions},
      () async {
        if (deleteTransactions) {
          await _transactionsRepo.deleteTransactionsByGoalId(id);
        }
        await _goalsRef(uid).doc(id).delete();
      },
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to delete goal: $e'));
  }

  @override
  Future<List<ScheduledPaymentModel>> getScheduledPayments() async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<List<ScheduledPaymentModel>>(
      'Firestore.getScheduledPayments',
      {},
      () async {
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
      serializeResponse: (m) => {'count': m.length},
    ).catchError((e) =>
        throw Exception('Failed to get scheduled payments: $e'));
  }

  @override
  Future<ScheduledPaymentModel> createScheduledPayment({
    required ScheduledPaymentModel payment,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<ScheduledPaymentModel>(
      'Firestore.createScheduledPayment',
      {'amount': payment.amount, 'frequency': payment.frequency.toJson()},
      () async {
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
      serializeResponse: (p) => {'id': p.id},
    ).catchError((e) =>
        throw Exception('Failed to create scheduled payment: $e'));
  }

  @override
  Future<ScheduledPaymentModel> updateScheduledPayment({
    required ScheduledPaymentModel payment,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<ScheduledPaymentModel>(
      'Firestore.updateScheduledPayment',
      {'id': payment.id},
      () async {
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
      serializeResponse: (p) => {'id': p.id},
    ).catchError((e) =>
        throw Exception('Failed to update scheduled payment: $e'));
  }

  @override
  Future<void> deleteScheduledPayment(String id) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteScheduledPayment',
      {'id': id},
      () => _scheduledPaymentsRef(uid).doc(id).delete(),
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) =>
        throw Exception('Failed to delete scheduled payment: $e'));
  }
}
