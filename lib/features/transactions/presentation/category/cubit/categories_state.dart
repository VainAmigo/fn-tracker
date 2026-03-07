part of 'categories_cubit.dart';

sealed class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesEmpty extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;

  CategoriesLoaded({required this.categories});
}

class CategoriesError extends CategoriesState {
  final String message;

  CategoriesError({required this.message});
}
