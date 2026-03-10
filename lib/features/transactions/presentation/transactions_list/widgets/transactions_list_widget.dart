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
          TransactionsEmpty() => const EmptyCardWidget(
            title: 'No transactions',
            subtitle: 'You have no transactions yet',
          ),
          TransactionsLoaded() => _Body(transactions: state.transactions),
          TransactionDeleted() =>
            state.transactions.isEmpty
                ? const EmptyCardWidget(
                    title: 'No transactions',
                    subtitle: 'You have no transactions yet',
                  )
                : _Body(transactions: state.transactions),
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

    final grouped = _groupByDayKey(transactions);
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      itemCount: sortedKeys.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizing.spaceBtwElements),
      itemBuilder: (context, sectionIndex) {
        final dayKey = sortedKeys[sectionIndex];
        final date = DateTime.parse(dayKey);
        final txList = grouped[dayKey]!;

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

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<TransactionsCubit>().deleteTransaction(tx.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: switch (radius) {
            CategoryCardRadius.single => BorderRadius.circular(
              AppSizing.borderRadius12,
            ),
            CategoryCardRadius.first => const BorderRadius.only(
              topLeft: Radius.circular(AppSizing.borderRadius12),
              topRight: Radius.circular(AppSizing.borderRadius12),
              bottomLeft: Radius.circular(AppSizing.borderRadius4),
              bottomRight: Radius.circular(AppSizing.borderRadius4),
            ),
            CategoryCardRadius.last => const BorderRadius.only(
              topLeft: Radius.circular(AppSizing.borderRadius4),
              topRight: Radius.circular(AppSizing.borderRadius4),
              bottomLeft: Radius.circular(AppSizing.borderRadius12),
              bottomRight: Radius.circular(AppSizing.borderRadius12),
            ),
            CategoryCardRadius.middle => BorderRadius.circular(
              AppSizing.borderRadius4,
            ),
          },
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: CategoryCard(
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
        trailing: AmountTextWidget(
          amount: tx.amount,
          style: AppTextStyles.listTileTitle(context),
        ),
        radius: radius,
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupByDayKey(
    List<TransactionModel> transactions,
  ) {
    final map = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      map.putIfAbsent(tx.dayKey, () => []).add(tx);
    }
    return map;
  }

  List<CategoryModel> _extractCategories(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded s => s.categories,
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
