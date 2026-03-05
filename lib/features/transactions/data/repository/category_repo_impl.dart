import 'package:fn_tracker/features/features.dart';

abstract class CategoryRepoImpl {
  Future<List<CategoryModel>> getUserCategories();

  Future<CategoryModel> addCategory({CategoryModel category});

  Future<CategoryModel> updateCategory({required CategoryModel category});

  Future<void> deleteCategory({required String categoryId});
}
