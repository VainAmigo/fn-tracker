import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class QuickCategoriesWidget extends StatefulWidget {
  const QuickCategoriesWidget({super.key});

  @override
  State<QuickCategoriesWidget> createState() => _QuickCategoriesWidgetState();
}

class _QuickCategoriesWidgetState extends State<QuickCategoriesWidget> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories();
    context.read<TransactionsCubit>().loadTransactionsByPeriod(
      TransactionPeriod.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      QuickCategoriesSettingsCubit,
      QuickCategoriesSettingsState
    >(
      builder: (context, settingsState) {
        final displayMode = settingsState.displayMode;
        final pinnedOrder = settingsState.pinnedOrder;
        return BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, categoriesState) {
            return BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, transactionsState) {
                final categories = _extractCategories(categoriesState);
                final transactions = _extractTransactions(transactionsState);
                final items = _getDisplayCategories(
                  displayMode,
                  categories,
                  transactions,
                  pinnedOrder,
                );

                final isLoading =
                    categoriesState is CategoriesLoading ||
                    transactionsState is TransactionsLoading;

                if (isLoading) {
                  return const SizedBox(
                    height: AppSizing.heightM,
                    child: Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return _EmptyState(displayMode: displayMode);
                }

                return SizedBox(
                  height: AppSizing.heightL,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizing.spaceBtwItems,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSizing.spaceBtwItemsExtra),
                    itemBuilder: (context, index) {
                      final category = items[index];
                      return _CategoryChip(
                        category: category,
                        onTap: () => _onCategoryTap(context, category),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<CategoryModel> _getDisplayCategories(
    QuickCategoriesDisplayMode mode,
    List<CategoryModel> categories,
    List<TransactionModel> transactions,
    List<String> pinnedOrder,
  ) {
    return switch (mode) {
      QuickCategoriesDisplayMode.pinned => _getPinnedCategories(
          categories,
          pinnedOrder,
        ),
      QuickCategoriesDisplayMode.recent => _getRecentCategories(
        categories,
        transactions,
      ),
    };
  }

  List<CategoryModel> _getPinnedCategories(
    List<CategoryModel> categories,
    List<String> pinnedOrder,
  ) {
    final pinned = categories.where((c) => c.isQuick == true).toList();
    if (pinnedOrder.isEmpty) return pinned;

    final categoryMap = {for (final c in pinned) c.categoryId: c};
    final result = <CategoryModel>[];

    for (final id in pinnedOrder) {
      if (categoryMap.containsKey(id)) {
        result.add(categoryMap[id]!);
      }
    }

    for (final c in pinned) {
      if (!pinnedOrder.contains(c.categoryId)) {
        result.add(c);
      }
    }

    return result;
  }

  List<CategoryModel> _getRecentCategories(
    List<CategoryModel> categories,
    List<TransactionModel> transactions,
  ) {
    final categoryMap = {for (final c in categories) c.categoryId: c};
    final seen = <String>{};
    final result = <CategoryModel>[];

    for (final tx in transactions.reversed) {
      final id = tx.categoryId;
      if (id != null &&
          id.isNotEmpty &&
          !seen.contains(id) &&
          categoryMap.containsKey(id)) {
        seen.add(id);
        result.add(categoryMap[id]!);
      }
    }

    return result;
  }

  List<CategoryModel> _extractCategories(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded s => s.categories,
      _ => const [],
    };
  }

  List<TransactionModel> _extractTransactions(TransactionsState state) {
    return switch (state) {
      TransactionsLoaded s => s.transactions,
      TransactionDeleted s => s.transactions,
      _ => const [],
    };
  }

  void _onCategoryTap(BuildContext context, CategoryModel category) {
    Navigator.of(
      context,
    ).pushNamed(AppRouter.addTransaction, arguments: category);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shade = findShadeById(category.colorId);
    final icon = findIconById(category.iconId);
    final color = shade?.color ?? Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
            ),
            child: Icon(
              icon?.icon ?? Icons.category,
              size: AppSizing.iconSizeL,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.displayMode});

  final QuickCategoriesDisplayMode displayMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(AppSizing.spaceBtwElements),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
      ),
      child: Center(
        child: Text(
          displayMode == QuickCategoriesDisplayMode.pinned
              ? 'Pin categories in settings for quick access'
              : 'Add transactions to see recent categories',
          style: AppTextStyles.listTileSubtitle(context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
