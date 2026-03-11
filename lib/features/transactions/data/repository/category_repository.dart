import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/features.dart';

class CategoryRepository implements CategoryRepoImpl {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  String _requireUid() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid).collection('categories');

  @override
  Future<List<CategoryModel>> getUserCategories() async {
    try {
      final uid = _requireUid();

      final categoriesSnapshot = await _categoriesRef(
        uid,
      ).orderBy('createdAt', descending: true).get();

      return categoriesSnapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories with subCategories: $e');
    }
  }

  @override
  Future<CategoryModel> addCategory({CategoryModel? category}) async {
    final uid = _requireUid();
    try {
      final now = Timestamp.now();
      final docRef = _categoriesRef(uid).doc();

      final model = CategoryModel(
        categoryId: docRef.id,
        name: category!.name,
        colorId: category.colorId,
        iconId: category.iconId,
        limitValue: category.limitValue,
        createdAt: now.toDate(),
      );

      await docRef.set({
        'categoryId': model.categoryId,
        'name': model.name,
        'colorId': model.colorId,
        'iconId': model.iconId,
        'limitValue': model.limitValue,
        'createdAt': now,
      });

      return model;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required CategoryModel category,
  }) async {
    final uid = _requireUid();
    try {
      final docRef = _categoriesRef(uid).doc(category.categoryId);

      final data = {
        'name': category.name,
        'colorId': category.colorId,
        'iconId': category.iconId,
        'isQuick': category.isQuick,
        'limitValue': category.limitValue,
      };

      await docRef.update(data);

      final snapshot = await docRef.get();
      return CategoryModel.fromJson(snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory({required String categoryId}) async {
    final uid = _requireUid();
    try {
      await _categoriesRef(uid).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
