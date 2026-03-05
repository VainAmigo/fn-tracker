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

  Future<void> createCategory({required CategoryModel categoryModel}) async {
    final previousCategories = _currentCategoriesOrNull() ?? [];

    emit(CategoryCreating(previousCategories: previousCategories));

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

      final updatedCategories = [createdCategory, ...previousCategories];

      emit(
        CategoryCreateSuccess(
          categories: updatedCategories,
          createdCategory: createdCategory,
        ),
      );
    } catch (e) {
      emit(
        CategoryCreateError(
          message: e.toString(),
          previousCategories: previousCategories,
        ),
      );
    }
  }

  Future<void> updateCategory({required CategoryModel categoryModel}) async {
    final previousCategories = _currentCategoriesOrNull() ?? [];

    emit(CategoryUpdating(previousCategories: previousCategories));

    try {
      final updatedCategory =
          await categoryRepo.updateCategory(category: categoryModel);

      final updatedCategories = previousCategories
          .map((c) =>
              c.categoryId == updatedCategory.categoryId ? updatedCategory : c)
          .toList();

      emit(
        CategoryUpdateSuccess(
          categories: updatedCategories,
          updatedCategory: updatedCategory,
        ),
      );
    } catch (e) {
      emit(
        CategoryUpdateError(
          message: e.toString(),
          previousCategories: previousCategories,
        ),
      );
    }
  }

  Future<void> deleteCategory({required String categoryId}) async {
    final previousCategories = _currentCategoriesOrNull() ?? [];

    emit(CategoryDeleting(previousCategories: previousCategories));

    try {
      await categoryRepo.deleteCategory(categoryId: categoryId);

      final updatedCategories =
          previousCategories.where((c) => c.categoryId != categoryId).toList();

      if (updatedCategories.isEmpty) {
        emit(CategoriesEmpty());
      } else {
        emit(
          CategoryDeleteSuccess(
            categories: updatedCategories,
            deletedCategoryId: categoryId,
          ),
        );
      }
    } catch (e) {
      emit(
        CategoryDeleteError(
          message: e.toString(),
          previousCategories: previousCategories,
        ),
      );
    }
  }

  List<CategoryModel>? _currentCategoriesOrNull() {
    final currentState = state;

    if (currentState is CategoriesLoaded) {
      return currentState.categories;
    }

    if (currentState is CategoryCreating) {
      return currentState.previousCategories;
    }

    if (currentState is CategoryCreateSuccess) {
      return currentState.categories;
    }

    if (currentState is CategoryCreateError) {
      return currentState.previousCategories;
    }

    if (currentState is CategoryUpdating) {
      return currentState.previousCategories;
    }

    if (currentState is CategoryUpdateSuccess) {
      return currentState.categories;
    }

    if (currentState is CategoryUpdateError) {
      return currentState.previousCategories;
    }

    if (currentState is CategoryDeleting) {
      return currentState.previousCategories;
    }

    if (currentState is CategoryDeleteSuccess) {
      return currentState.categories;
    }

    if (currentState is CategoryDeleteError) {
      return currentState.previousCategories;
    }

    return null;
  }
}
