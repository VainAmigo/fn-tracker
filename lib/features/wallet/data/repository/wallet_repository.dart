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

  @override
  Future<WalletModel> addWallet({required WalletModel wallet}) async {
    final uid = _requireUid();
    try {
      final docRef = _walletsRef(uid).doc();
      await docRef.set({
        'id': docRef.id,
        'name': wallet.name,
        'colorId': wallet.colorId,
        'iconId': wallet.iconId,
        'isDefault': wallet.isDefault,
      });
      return wallet;
    } catch (e) {
      throw Exception('Failed to add wallet: $e');
    }
  }

  @override
  Future<WalletModel> updateWallet({required WalletModel wallet}) async {
    final uid = _requireUid();
    try {
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
      await _walletsRef(uid).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final uid = _requireUid();

    try {
      final results = await Future.wait([
        _walletsRef(uid).get(),
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
  Future<BudgetStatModel> getBudgetStats({required String periodKey}) async {
    final uid = _requireUid();
    try {
      final results = await Future.wait([
        _budgetsRef(uid).get(),
        _transactionsRef(uid)
            .where('periodKey', isEqualTo: periodKey)
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

      final expenseType = TransactionType.expense.toJson();

      final transactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .where((t) => t.type == TransactionType.expense)
          .toList();

      final totalForPeriod = transactionsSnapshot.docs
          .where((doc) => doc.data()['type'] == expenseType)
          .fold<double>(
            0.0,
            (double sum, doc) => sum + (doc.data()['amount'] as num).toDouble(),
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
}
