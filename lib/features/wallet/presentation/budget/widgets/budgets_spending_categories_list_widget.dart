import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class BudgetsSpendingCategoriesListWidget extends StatelessWidget {
  const BudgetsSpendingCategoriesListWidget({
    super.key,
    required this.categorySpending,
    required this.currency,
  });

  final List<CategorySpending> categorySpending;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    if (categorySpending.isEmpty) return const SizedBox.shrink();

    final total = categorySpending.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitledSection(
          title: 'Spending by category',
          children: [
            for (int i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(height: AppSizing.spaceBtwItemsExtra),
              _SpendingCategoryCard(
                spending: categorySpending[i],
                currency: currency,
                radius: _radiusForIndex(i, total),
              ),
            ],
          ],
        ),
      ],
    );
  }

  CategoryCardRadius _radiusForIndex(int index, int total) {
    if (total == 1) return CategoryCardRadius.single;
    if (index == 0) return CategoryCardRadius.first;
    if (index == total - 1) return CategoryCardRadius.last;
    return CategoryCardRadius.middle;
  }
}

class _SpendingCategoryCard extends StatelessWidget {
  const _SpendingCategoryCard({
    required this.spending,
    required this.currency,
    required this.radius,
  });

  final CategorySpending spending;
  final Currency currency;
  final CategoryCardRadius radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = CurrencyFormatter(currency);
    final category = spending.category;
    final spent = spending.amount;

    final shade = findShadeById(category.colorId);
    final icon = findIconById(category.iconId);
    final color = shade?.color ?? Colors.grey;

    final limit = category.limitValue;
    final hasLimit = limit != null && limit > 0;
    final exceeded = hasLimit && spent > limit;

    final borderRadius = switch (radius) {
      CategoryCardRadius.first => BorderRadius.only(
        topLeft: Radius.circular(AppSizing.borderRadius12),
        topRight: Radius.circular(AppSizing.borderRadius12),
        bottomLeft: Radius.circular(AppSizing.borderRadius4),
        bottomRight: Radius.circular(AppSizing.borderRadius4),
      ),
      CategoryCardRadius.last => BorderRadius.only(
        topLeft: Radius.circular(AppSizing.borderRadius4),
        topRight: Radius.circular(AppSizing.borderRadius4),
        bottomLeft: Radius.circular(AppSizing.borderRadius12),
        bottomRight: Radius.circular(AppSizing.borderRadius12),
      ),
      CategoryCardRadius.middle => BorderRadius.circular(
        AppSizing.borderRadius4,
      ),
      CategoryCardRadius.single => BorderRadius.circular(
        AppSizing.borderRadius12,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSizing.spaceBtwElements),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
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
              const SizedBox(width: AppSizing.spaceBtwItems),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTextStyles.listTileTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatter.format(spent),
                style: AppTextStyles.listTileTitle(
                  context,
                ).copyWith(color: exceeded ? colorScheme.error : null),
              ),
            ],
          ),
          if (hasLimit) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            SegmentedBar(
              height: 6,
              gap: 3,
              segments: exceeded
                  ? [
                      BarChartSegment(
                        value: spent > limit ? spent - limit : spent,
                        color: colorScheme.error,
                      ),
                      BarChartSegment(
                        value: spent > limit ? 0 : limit,
                        color: colorScheme.onSecondary,
                      ),
                    ]
                  : [
                      BarChartSegment(value: spent, color: colorScheme.primary),
                      BarChartSegment(
                        value: limit - spent,
                        color: colorScheme.onSecondary,
                      ),
                    ],
              trackColor: colorScheme.secondary,
            ),
            const SizedBox(height: AppSizing.spaceBtwElements),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatter.format(spent)} / ${formatter.format(limit)}',
                  style: AppTextStyles.listTileSubtitle(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  exceeded
                      ? 'Limit exceeded'
                      : '${((limit - spent) / limit * 100).clamp(0, 100).toStringAsFixed(0)}% remaining',
                  style: AppTextStyles.listTileSubtitle(context).copyWith(
                    color: exceeded
                        ? colorScheme.error
                        : colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
