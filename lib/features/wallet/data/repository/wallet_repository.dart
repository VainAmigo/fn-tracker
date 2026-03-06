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
}
