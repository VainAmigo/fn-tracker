import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class TransactionsListWidget extends StatelessWidget {
  const TransactionsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        return switch (state) {
          TransactionsInitial() => const SizedBox.shrink(),
          TransactionsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          TransactionsEmpty() => const Center(child: Text('No transactions')),
          TransactionsLoaded() => _Body(transactions: state.transactions),
          TransactionsError() => Center(child: Text(state.message)),
        };
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    final categoriesState = context.watch<CategoriesCubit>().state;
    final categories = _extractCategories(categoriesState);
    final categoryMap = {for (final c in categories) c.categoryId: c};
    final currency = context.watch<CurrencyProvider>().currency;

    final grouped = _groupByDate(transactions);
    final entries = grouped.entries.toList();

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizing.spaceBtwElements),
      itemBuilder: (context, sectionIndex) {
        final date = entries[sectionIndex].key;
        final txList = entries[sectionIndex].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              date.formatDayMonthYearUpper,
              style: AppTextStyles.sectionTitle(context),
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            for (int i = 0; i < txList.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSizing.spaceBtwItemsExtra),
              _buildTransactionCard(
                context,
                tx: txList[i],
                categoryMap: categoryMap,
                currency: currency,
                radius: _radiusForIndex(i, txList.length),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required TransactionModel tx,
    required Map<String, CategoryModel> categoryMap,
    required Currency currency,
    required CategoryCardRadius radius,
  }) {
    final category = categoryMap[tx.categoryId];
    final shade = category != null ? findShadeById(category.colorId) : null;
    final icon = category != null ? findIconById(category.iconId) : null;
    final color = shade?.color ?? Colors.grey;

    final isExpense = tx.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';
    final formattedAmount = AmountFormatter.format(
      tx.amount,
      decimalPlaces: currency.decimalPlaces,
    );

    return CategoryCard(
      title: category?.name ?? tx.categoryId ?? '',
      subtitle: tx.note.isNotEmpty ? tx.note : null,
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
      trailing: Text(
        '$sign $formattedAmount ${currency.symbol}',
        style: AppTextStyles.listTileTitle(
          context,
        ).copyWith(color: isExpense ? Colors.red : Colors.green),
      ),
      radius: radius,
    );
  }

  Map<DateTime, List<TransactionModel>> _groupByDate(
    List<TransactionModel> transactions,
  ) {
    final map = <DateTime, List<TransactionModel>>{};
    for (final tx in transactions) {
      final dateOnly = DateTime(
        tx.createdAt?.year ?? 0,
        tx.createdAt?.month ?? 0,
        tx.createdAt?.day ?? 0,
      );
      map.putIfAbsent(dateOnly, () => []).add(tx);
    }
    return map;
  }

  List<CategoryModel> _extractCategories(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded s => s.categories,
      CategoryCreateSuccess s => s.categories,
      CategoryCreating s => s.previousCategories,
      CategoryCreateError s => s.previousCategories ?? const [],
      CategoryUpdateSuccess s => s.categories,
      CategoryUpdating s => s.previousCategories,
      CategoryUpdateError s => s.previousCategories ?? const [],
      CategoryDeleteSuccess s => s.categories,
      CategoryDeleting s => s.previousCategories,
      CategoryDeleteError s => s.previousCategories ?? const [],
      _ => const [],
    };
  }

  CategoryCardRadius _radiusForIndex(int index, int total) {
    if (total == 1) return CategoryCardRadius.single;
    if (index == 0) return CategoryCardRadius.first;
    if (index == total - 1) return CategoryCardRadius.last;
    return CategoryCardRadius.middle;
  }
}
