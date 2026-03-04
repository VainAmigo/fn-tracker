import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionCategorySheetWidget extends StatefulWidget {
  const AddTransactionCategorySheetWidget({super.key});

  @override
  State<AddTransactionCategorySheetWidget> createState() =>
      _AddTransactionCategorySheetWidgetState();
}

class _AddTransactionCategorySheetWidgetState
    extends State<AddTransactionCategorySheetWidget> {
  @override
  void initState() {
    context.read<CategoriesCubit>().loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
      ),
      width: double.infinity,
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose category',
            style: AppTextStyles.modalSheetTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Expanded(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading || state is CategoriesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CategoriesError) {
                  return Center(
                    child: Text(state.message, textAlign: TextAlign.center),
                  );
                }

                final categories = switch (state) {
                  CategoriesLoaded s => s.categories,
                  CategoryCreateSuccess s => s.categories,
                  CategoryCreating s => s.previousCategories,
                  CategoryCreateError s =>
                    s.previousCategories ?? const <CategoryModel>[],
                  CategoriesEmpty _ => const <CategoryModel>[],
                  _ => const <CategoryModel>[],
                };

                if (categories.isEmpty) {
                  return const Center(child: Text('Категорий пока нет'));
                }

                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(category),
                      child: CategoryCard(
                        title: category.name,
                        style: CategoryCardStyle.outlined,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
