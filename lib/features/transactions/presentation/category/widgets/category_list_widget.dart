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
    this.dismissible = true,
  });

  final ValueChanged<CategoryModel>? onCategorySelected;
  final CategoryCardStyle cardStyle;
  final bool shrinkWrap;
  final bool autoLoad;
  final bool dismissible;

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
    final total = categories.length + 1;

    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: total,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
      itemBuilder: (context, index) {
        if (index == categories.length) {
          final colorScheme = Theme.of(context).colorScheme;
          return CategoryCard(
            title: 'New category',
            leading: Container(
              height: AppSizing.heightS,
              decoration: BoxDecoration(
                color: colorScheme.onSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  Icons.add_rounded,
                  size: AppSizing.iconSizeM,
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
            style: widget.cardStyle,
            radius: radiusForIndex(index, total),
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.createCategory),
          );
        }

        final category = categories[index];
        final shade = findShadeById(category.colorId);
        final icon = findIconById(category.iconId);
        final color = shade?.color ?? Colors.grey;
        final radius = radiusForIndex(index, total);

        final card = CategoryCard(
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
          radius: radius,
          onTap: widget.onCategorySelected != null
              ? () => widget.onCategorySelected!(category)
              : null,
        );

        if (!widget.dismissible) return card;

        return Dismissible(
          key: Key(category.categoryId),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            context.read<CategoriesCubit>().deleteCategory(
                  categoryId: category.categoryId,
                );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: borderRadiusFor(radius),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: card,
        );
      },
    );
  }
}
