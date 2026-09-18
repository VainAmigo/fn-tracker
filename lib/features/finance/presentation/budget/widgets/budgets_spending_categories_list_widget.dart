import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

class BudgetsSpendingCategoriesListWidget extends StatelessWidget {
  const BudgetsSpendingCategoriesListWidget({
    super.key,
    required this.categorySpending,
    required this.onCategoryTap,
  });

  final List<CategorySpending> categorySpending;
  final void Function(CategorySpending spending) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categorySpending.isEmpty) return const SizedBox.shrink();

    final total = categorySpending.length;
    final currency = context.watch<CurrencyProvider>().currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitledSection(
          title: context.l10n.budgetCategories,
          children: [
            for (int i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(height: AppSizing.spaceBtwItemsExtra),
              _SpendingCategoryCard(
                spending: categorySpending[i],
                currency: currency,
                radius: radiusForIndex(i, total),
                onTap: () => onCategoryTap(categorySpending[i]),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SpendingCategoryCard extends StatelessWidget {
  const _SpendingCategoryCard({
    required this.spending,
    required this.currency,
    required this.radius,
    required this.onTap,
  });

  final CategorySpending spending;
  final Currency currency;
  final CardRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final category = spending.category;
    final spent = spending.amount;

    final shade = findShadeById(category.colorId);
    final icon = findIconById(category.iconId);
    final color = shade?.color ?? Colors.grey;

    final limit = spending.resolvedLimit;
    final hasLimit = limit != null && limit > 0;
    final exceeded = hasLimit && spent > limit;

    final limitLabel = BudgetDisplayUtils.formatCategoryLimit(
      category,
      currencySymbol: currency.symbol,
      formatAmount: (a) => AmountFormatter.format(a),
    );

    final borderRadius = borderRadiusFor(radius);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    borderRadius: BorderRadius.circular(
                      AppSizing.borderRadius8,
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTextStyles.listTileTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (limitLabel != null)
                        Text(
                          limitLabel,
                          style: AppTextStyles.listTileSubtitle(context),
                        ),
                    ],
                  ),
                ),
                AmountTextWidget(
                  amount: spent,
                  style: AppTextStyles.listTileTitle(context),
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
                        BarChartSegment(
                          value: spent,
                          color: colorScheme.primary,
                        ),
                        BarChartSegment(
                          value: limit - spent,
                          color: colorScheme.onSecondary,
                        ),
                      ],
                trackColor: colorScheme.secondary,
              ),
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AmountDividerWidget(leftAmount: spent, rightAmount: limit),
                  Text(
                    exceeded
                        ? context.l10n.limitExceeded
                        : '${((limit - spent) / limit * 100).clamp(0, 100).toStringAsFixed(0)}% ${context.l10n.remaining}',
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
      ),
    );
  }
}
