part of 'categories_cubit.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesEmpty extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;

  CategoriesLoaded({
    required this.categories,
  });
}

class CategoriesError extends CategoriesState {
  final String message;

  CategoriesError({
    required this.message,
  });
}

class CategoryCreating extends CategoriesState {
  final List<CategoryModel> previousCategories;

  CategoryCreating({
    required this.previousCategories,
  });
}

class CategoryCreateSuccess extends CategoriesState {
  final List<CategoryModel> categories;
  final CategoryModel createdCategory;

  CategoryCreateSuccess({
    required this.categories,
    required this.createdCategory,
  });
}

class CategoryCreateError extends CategoriesState {
  final String message;
  final List<CategoryModel>? previousCategories;

  CategoryCreateError({
    required this.message,
    required this.previousCategories,
  });
}

// Update states

class CategoryUpdating extends CategoriesState {
  final List<CategoryModel> previousCategories;

  CategoryUpdating({required this.previousCategories});
}

class CategoryUpdateSuccess extends CategoriesState {
  final List<CategoryModel> categories;
  final CategoryModel updatedCategory;

  CategoryUpdateSuccess({
    required this.categories,
    required this.updatedCategory,
  });
}

class CategoryUpdateError extends CategoriesState {
  final String message;
  final List<CategoryModel>? previousCategories;

  CategoryUpdateError({
    required this.message,
    required this.previousCategories,
  });
}

// Delete states

class CategoryDeleting extends CategoriesState {
  final List<CategoryModel> previousCategories;

  CategoryDeleting({required this.previousCategories});
}

class CategoryDeleteSuccess extends CategoriesState {
  final List<CategoryModel> categories;
  final String deletedCategoryId;

  CategoryDeleteSuccess({
    required this.categories,
    required this.deletedCategoryId,
  });
}

class CategoryDeleteError extends CategoriesState {
  final String message;
  final List<CategoryModel>? previousCategories;

  CategoryDeleteError({
    required this.message,
    required this.previousCategories,
  });
}