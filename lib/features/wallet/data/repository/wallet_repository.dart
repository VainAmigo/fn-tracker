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

  CollectionReference<Map<String, dynamic>> _walletsRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('wallets');

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('goals');

  CollectionReference<Map<String, dynamic>> _scheduledPaymentsRef(String uid) =>
      firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('scheduled_payments');

  @override
  Future<WalletModel> addWallet({required WalletModel wallet}) async {
    final uid = _requireUid();
    try {
      final existing = await _walletsRef(uid).get();
      final isFirst = existing.docs.isEmpty;

      final docRef = _walletsRef(uid).doc();
      final created = wallet.copyWith(id: docRef.id, isDefault: isFirst);
      await docRef.set(created.toJson());
      return created;
    } catch (e) {
      throw Exception('Failed to add wallet: $e');
    }
  }

  @override
  Future<WalletModel> updateWallet({required WalletModel wallet}) async {
    final uid = _requireUid();
    try {
      if (wallet.isDefault) {
        await setDefaultWallet(wallet.id!);
      }
      final docRef = _walletsRef(uid).doc(wallet.id);
      await docRef.update(wallet.toJson());
      return wallet;
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    final uid = _requireUid();
    try {
      final walletDoc = await _walletsRef(uid).doc(id).get();
      final wasDefault = walletDoc.data()?['isDefault'] == true;

      await _walletsRef(uid).doc(id).delete();

      if (wasDefault) {
        final remaining = await _walletsRef(uid).limit(1).get();
        if (remaining.docs.isNotEmpty) {
          await remaining.docs.first.reference.update({'isDefault': true});
        }
      }
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  @override
  Future<void> setDefaultWallet(String walletId) async {
    final uid = _requireUid();
    try {
      final snapshot = await _walletsRef(uid).get();
      final batch = firebaseFirestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': doc.id == walletId});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to set default wallet: $e');
    }
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final uid = _requireUid();

    try {
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

      /// walletId -> balance
      final Map<String, double> balances = {};

      for (final t in transactions) {
        final current = balances[t.walletId] ?? 0;

        if (t.type == TransactionType.income) {
          balances[t.walletId ?? ''] = current + t.amount;
        } else {
          balances[t.walletId ?? ''] = current - t.amount;
        }
      }

      return wallets.map((wallet) {
        final balance = balances[wallet.id] ?? 0;

        return wallet.copyWith(balance: balance);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get wallets: $e');
    }
  }

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
  Future<BudgetStatModel> getBudgetStats({
    required String startDayKey,
    required String endDayKey,
  }) async {
    final uid = _requireUid();
    try {
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
    } catch (e) {
      throw Exception('Failed to get budget stats: $e');
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
  Future<GoalsModel> getGoals() async {
    final uid = _requireUid();
    try {
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
      final completedCount = goals
          .where((g) => g.targetAmount > 0 && g.progress >= g.targetAmount)
          .length;

      return GoalsModel(
        goals: goals,
        totalGoal: TotalGoalModel(
          totalProgress: totalProgress,
          totalTargetAmount: totalTarget,
          goalsCount: goals.length,
          completedCount: completedCount,
        ),
      );
    } catch (e) {
      throw Exception('Failed to get goals: $e');
    }
  }

  @override
  Future<GoalModel> createGoal({required GoalModel goal}) async {
    final uid = _requireUid();
    try {
      final docRef = _goalsRef(uid).doc();
      final created = goal.copyWith(id: docRef.id);
      await docRef.set(created.toJson());
      return created;
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  @override
  Future<GoalModel> updateGoal({required GoalModel goal}) async {
    final uid = _requireUid();
    try {
      final docRef = _goalsRef(uid).doc(goal.id);
      await docRef.update(goal.toJson());
      return goal;
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    final uid = _requireUid();
    try {
      await _goalsRef(uid).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  @override
  Future<List<ScheduledPaymentModel>> getScheduledPayments() async {
    final uid = _requireUid();
    try {
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
      models.sort((a, b) => (b.createdAt ?? b.nextDate)
          .compareTo(a.createdAt ?? a.nextDate));
      return models;
    } catch (e) {
      throw Exception('Failed to get scheduled payments: $e');
    }
  }

  @override
  Future<ScheduledPaymentModel> createScheduledPayment({
    required ScheduledPaymentModel payment,
  }) async {
    final uid = _requireUid();
    try {
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
    } catch (e) {
      throw Exception('Failed to create scheduled payment: $e');
    }
  }

  @override
  Future<ScheduledPaymentModel> updateScheduledPayment({
    required ScheduledPaymentModel payment,
  }) async {
    final uid = _requireUid();
    try {
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
    } catch (e) {
      throw Exception('Failed to update scheduled payment: $e');
    }
  }

  @override
  Future<void> deleteScheduledPayment(String id) async {
    final uid = _requireUid();
    try {
      await _scheduledPaymentsRef(uid).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete scheduled payment: $e');
    }
  }
}
