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