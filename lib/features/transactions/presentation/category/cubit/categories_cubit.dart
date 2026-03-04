import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepoImpl categoryRepo;

  CategoriesCubit({
    required this.categoryRepo,
  }) : super(CategoriesInitial());

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

  Future<void> createCategory({
    required String name,
    required String currency,
    required String colorId,
    required String iconId,
    double? limitValue,
  }) async {
    final trimmedName = name.trim();
    final trimmedCurrency = currency.trim();

    if (trimmedName.isEmpty) {
      emit(
        CategoryCreateError(
          message: 'Category name cannot be empty',
          previousCategories: _currentCategoriesOrNull(),
        ),
      );
      return;
    }

    if (trimmedCurrency.isEmpty) {
      emit(
        CategoryCreateError(
          message: 'Currency cannot be empty',
          previousCategories: _currentCategoriesOrNull(),
        ),
      );
      return;
    }

    final previousCategories = _currentCategoriesOrNull() ?? [];

    emit(
      CategoryCreating(
        previousCategories: previousCategories,
      ),
    );

    try {
      // categoryId and createdAt will be overwritten by repository
      final draft = CategoryModel(
        categoryId: '',
        name: trimmedName,
        colorId: colorId,
        iconId: iconId,
        currency: trimmedCurrency,
        limitValue: limitValue,
        createdAt: DateTime.now(),
      );

      final createdCategory = await categoryRepo.addCategory(
        category: draft,
      );

      final updatedCategories = [
        createdCategory,
        ...previousCategories,
      ];

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

    return null;
  }
}