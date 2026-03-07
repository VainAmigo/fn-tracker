import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepoImpl categoryRepo;

  CategoriesCubit({required this.categoryRepo}) : super(CategoriesInitial());

  Future<void> loadCategories() async {
    try {
      emit(CategoriesLoading());
      final categories = await categoryRepo.getUserCategories();

      if (categories.isEmpty) {
        emit(CategoriesEmpty());
      } else {
        emit(CategoriesLoaded(categories: categories));
      }
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }

  List<CategoryModel> get currentCategories =>
      state is CategoriesLoaded ? (state as CategoriesLoaded).categories : [];

  List<CategoryModel> get _currentCategories => currentCategories;

  Future<void> createCategory({required CategoryModel categoryModel}) async {
    final previous = _currentCategories;
    emit(CategoriesLoading());

    try {
      final draft = CategoryModel(
        categoryId: '',
        name: categoryModel.name,
        colorId: categoryModel.colorId,
        iconId: categoryModel.iconId,
        limitValue: categoryModel.limitValue,
        createdAt: DateTime.now(),
      );

      final createdCategory = await categoryRepo.addCategory(category: draft);
      emit(CategoriesLoaded(categories: [createdCategory, ...previous]));
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }

  Future<void> updateCategory({required CategoryModel categoryModel}) async {
    final previous = _currentCategories;
    emit(CategoriesLoading());

    try {
      final updatedCategory =
          await categoryRepo.updateCategory(category: categoryModel);

      final updatedCategories = previous
          .map((c) =>
              c.categoryId == updatedCategory.categoryId ? updatedCategory : c)
          .toList();

      emit(CategoriesLoaded(categories: updatedCategories));
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }

  Future<void> deleteCategory({required String categoryId}) async {
    final previous = _currentCategories;
    emit(CategoriesLoading());

    try {
      await categoryRepo.deleteCategory(categoryId: categoryId);

      final updatedCategories =
          previous.where((c) => c.categoryId != categoryId).toList();

      if (updatedCategories.isEmpty) {
        emit(CategoriesEmpty());
      } else {
        emit(CategoriesLoaded(categories: updatedCategories));
      }
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }
}
