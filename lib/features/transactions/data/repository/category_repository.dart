import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

class CategoryRepository
    with FirestoreUserContext
    implements CategoryRepoImpl {
  @override
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) =>
      FirestorePaths.categoriesRef(firebaseFirestore, uid);

  @override
  Future<List<CategoryModel>> getUserCategories() async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<List<CategoryModel>>(
      'Firestore.getUserCategories',
      {},
      () async {
        final snapshot = await _categoriesRef(uid)
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data()))
            .toList();
      },
      serializeResponse: (c) => {'count': c.length},
    ).catchError((e) =>
        throw Exception('Failed to fetch categories with subCategories: $e'));
  }

  @override
  Future<CategoryModel> addCategory({CategoryModel? category}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<CategoryModel>(
      'Firestore.addCategory',
      {'name': category!.name},
      () async {
        final now = Timestamp.now();
        final docRef = _categoriesRef(uid).doc();
        final model = CategoryModel(
          categoryId: docRef.id,
          name: category.name,
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
      },
      serializeResponse: (c) => {'categoryId': c.categoryId, 'name': c.name},
    ).catchError((e) => throw Exception('Failed to add category: $e'));
  }

  @override
  Future<CategoryModel> updateCategory({
    required CategoryModel category,
  }) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<CategoryModel>(
      'Firestore.updateCategory',
      {'categoryId': category.categoryId, 'name': category.name},
      () async {
        final docRef = _categoriesRef(uid).doc(category.categoryId);
        await docRef.update({
          'name': category.name,
          'colorId': category.colorId,
          'iconId': category.iconId,
          'isQuick': category.isQuick,
          'limitValue': category.limitValue,
        });
        final snapshot = await docRef.get();
        return CategoryModel.fromJson(snapshot.data()!);
      },
      serializeResponse: (c) => {'categoryId': c.categoryId},
    ).catchError((e) => throw Exception('Failed to update category: $e'));
  }

  @override
  Future<void> deleteCategory({required String categoryId}) async {
    final uid = requireUid();
    return FirebaseLogger.withLogging<void>(
      'Firestore.deleteCategory',
      {'categoryId': categoryId},
      () => _categoriesRef(uid).doc(categoryId).delete(),
      serializeResponse: (_) => {'ok': true},
    ).catchError((e) => throw Exception('Failed to delete category: $e'));
  }
}
