import 'package:fn_tracker/features/features.dart';

abstract class CategoryRepoImpl {
  Future<List<CategoryModel>> getUserCategories();

  Future<CategoryModel> addCategory({CategoryModel category});
}
