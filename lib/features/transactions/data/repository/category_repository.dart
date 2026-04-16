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

  String _collectionPath(String uid) => 'users/$uid/categories';

  @override
  Future<List<CategoryModel>> getUserCategories() async {
    final uid = requireUid();
    return FirebaseLogger.query(
      operation: 'getUserCategories',
      collection: _collectionPath(uid),
      filters: {'orderBy': 'createdAt DESC'},
      fn: () async {
        final snapshot = await _categoriesRef(uid)
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data()))
            .toList();
      },
      serialize: (list) => {
        '_docsCount': list.length,
        '_docs': list.map((c) => {
          'categoryId': c.categoryId,
          'name': c.name,
          'colorId': c.colorId,
          'iconId': c.iconId,
          'limitValue': c.limitValue,
        }).toList(),
      },
    );
  }

  @override
  Future<CategoryModel> addCategory({CategoryModel? category}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'addCategory',
      collection: _collectionPath(uid),
      data: {
        'name': category!.name,
        'colorId': category.colorId,
        'iconId': category.iconId,
        'limitValue': category.limitValue,
      },
      fn: () async {
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
      serialize: (c) => {
        'categoryId': c.categoryId,
        'name': c.name,
      },
    );
  }

  @override
  Future<CategoryModel> updateCategory({
    required CategoryModel category,
  }) async {
    final uid = requireUid();
    final updateData = {
      'name': category.name,
      'colorId': category.colorId,
      'iconId': category.iconId,
      'isQuick': category.isQuick,
      'limitValue': category.limitValue,
    };
    return FirebaseLogger.mutation(
      operation: 'updateCategory',
      collection: _collectionPath(uid),
      docId: category.categoryId,
      data: updateData,
      fn: () async {
        final docRef = _categoriesRef(uid).doc(category.categoryId);
        await docRef.update(updateData);
        final snapshot = await docRef.get();
        return CategoryModel.fromJson(snapshot.data()!);
      },
      serialize: (c) => {
        'categoryId': c.categoryId,
        'name': c.name,
      },
    );
  }

  @override
  Future<void> deleteCategory({required String categoryId}) async {
    final uid = requireUid();
    return FirebaseLogger.mutation(
      operation: 'deleteCategory',
      collection: _collectionPath(uid),
      docId: categoryId,
      fn: () => _categoriesRef(uid).doc(categoryId).delete(),
    );
  }
}
