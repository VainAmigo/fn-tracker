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
    if (total == 1) return CategoryCardRadius.single;
    if (index == 0) return CategoryCardRadius.first;
    if (index == total - 1) return CategoryCardRadius.last;
    return CategoryCardRadius.middle;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        return switch (state) {
          CategoriesInitial() || CategoriesLoading() => SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          CategoriesError() => Center(
            child: Text(state.message, textAlign: TextAlign.center),
          ),
          CategoriesEmpty() => const EmptyCardWidget(
            title: 'No categories',
            subtitle: 'Create you first category',
          ),
          CategoriesLoaded() => _buildList(context, state.categories, currency),
        };
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    List<CategoryModel> categories,
    Currency currency,
  ) {
    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
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
  }
}
