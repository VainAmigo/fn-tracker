import 'package:fn_tracker/features/features.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'categories_state.dart';

class CategoriesCubit extends HydratedCubit<CategoriesState> {
  final CategoryRepoImpl categoryRepo;
  final TransactionsRepository transactionsRepo;

  CategoriesCubit({
    required this.categoryRepo,
    required this.transactionsRepo,
  }) : super(CategoriesInitial());

  @override
  String get storagePrefix => 'CategoriesCubit';

  @override
  CategoriesState? fromJson(Map<String, dynamic> json) {
    final type = json['_type'] as String?;
    return switch (type) {
      'loaded' => CategoriesLoaded(
          categories: (json['categories'] as List)
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      'empty' => CategoriesEmpty(),
      _ => null,
    };
  }

  @override
  Map<String, dynamic>? toJson(CategoriesState state) {
    if (state is CategoriesLoading ||
        state is CategoriesInitial ||
        state is CategoriesError) {
      return null; // Do not persist — keep previous cached state
    }
    if (state is CategoriesEmpty) return {'_type': 'empty'};
    if (state is CategoriesLoaded) {
      return {
        '_type': 'loaded',
        'categories': state.categories.map((c) => c.toJson()).toList(),
      };
    }
    return null;
  }

  void clearForLogout() => emit(CategoriesInitial());

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

  Future<void> deleteCategory({
    required String categoryId,
    required bool deleteTransactions,
  }) async {
    final previous = _currentCategories;
    emit(CategoriesLoading());

    try {
      if (deleteTransactions) {
        await transactionsRepo.deleteTransactionsByCategoryId(categoryId);
      }
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
