import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class CategoryListWidget extends StatefulWidget {
  const CategoryListWidget({
    super.key,
    this.onCategorySelected,
    this.cardStyle = CategoryCardStyle.filled,
    this.shrinkWrap = false,
    this.autoLoad = false,
  });

  final ValueChanged<CategoryModel>? onCategorySelected;
  final CategoryCardStyle cardStyle;
  final bool shrinkWrap;
  final bool autoLoad;

  @override
  State<CategoryListWidget> createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      context.read<CategoriesCubit>().loadCategories();
    }
  }

  CategoryCardRadius _radiusForIndex(int index, int total) {
    if (total == 1) return CategoryCardRadius.middle;
    if (index == 0) return CategoryCardRadius.first;
    if (index == total - 1) return CategoryCardRadius.last;
    return CategoryCardRadius.middle;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    return BlocBuilder<CategoriesCubit, CategoriesState>(
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
          CategoryUpdateSuccess s => s.categories,
          CategoryUpdating s => s.previousCategories,
          CategoryUpdateError s =>
            s.previousCategories ?? const <CategoryModel>[],
          CategoryDeleteSuccess s => s.categories,
          CategoryDeleting s => s.previousCategories,
          CategoryDeleteError s =>
            s.previousCategories ?? const <CategoryModel>[],
          CategoriesEmpty _ => const <CategoryModel>[],
          _ => const <CategoryModel>[],
        };

        if (categories.isEmpty) {
          return const Center(child: Text('Категорий пока нет'));
        }

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : null,
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          itemBuilder: (context, index) {
            final category = categories[index];
            final shade = findShadeById(category.colorId);
            final icon = findIconById(category.iconId);
            final color = shade?.color ?? Colors.grey;

            return CategoryCard(
              title: category.name,
              subtitle: category.limitValue != null
                  ? AmountFormatter.formatWithDots(
                      'Limit',
                      '${category.limitValue} ${currency.symbol}',
                    )
                  : null,
              leading: Container(
                height: AppSizing.heightS,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Icon(
                    icon?.icon ?? Icons.category,
                    size: AppSizing.iconSizeM,
                    color: color,
                  ),
                ),
              ),
              style: widget.cardStyle,
              radius: _radiusForIndex(index, categories.length),
              onTap: widget.onCategorySelected != null
                  ? () => widget.onCategorySelected!(category)
                  : null,
            );
          },
        );
      },
    );
  }
}
