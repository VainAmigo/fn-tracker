import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class LastTransactionsListWidget extends StatefulWidget {
  const LastTransactionsListWidget({super.key});

  @override
  State<LastTransactionsListWidget> createState() =>
      _LastTransactionsListWidgetState();
}

class _LastTransactionsListWidgetState
    extends State<LastTransactionsListWidget> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionsCubit>().loadTransactionsByPeriod(
      TransactionPeriod.month,
    );
  }

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
    final goals = _extractGoals(context.watch<GoalsCubit>().state);
    final goalMap = {for (final g in goals) g.id: g};
    final wallets = _extractWallets(context.watch<WalletCubit>().state);
    final walletMap = {
      for (final w in wallets)
        if (w.id != null) w.id!: w,
    };

    final visibleTransactions = _filterHiddenTransactions(
      transactions,
      walletMap,
      goalMap,
    );
    final lastItems = visibleTransactions.length > 10
        ? visibleTransactions.sublist(visibleTransactions.length - 10)
        : visibleTransactions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 0; index < lastItems.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          Builder(
            builder: (context) {
              final tx = lastItems[index];
              final isGoalTransaction =
                  tx.categoryId == null || tx.categoryId!.isEmpty;
              final goal = isGoalTransaction && tx.goalId != null
                  ? goalMap[tx.goalId]
                  : null;
              final category = !isGoalTransaction
                  ? categoryMap[tx.categoryId]
                  : null;
              final wallet = tx.walletId != null
                  ? walletMap[tx.walletId]
                  : null;

              final shade = category != null
                  ? findShadeById(category.colorId)
                  : goal != null
                  ? findShadeById(goal.colorId)
                  : wallet != null
                  ? findShadeById(wallet.colorId)
                  : null;
              final icon = category != null
                  ? findIconById(category.iconId)
                  : goal != null
                  ? findIconById(goal.iconId)
                  : wallet != null
                  ? findIconById(wallet.iconId)
                  : null;

              final fallbackColor = Theme.of(context).colorScheme.onSecondary;
              final resolvedColor = shade?.color ?? fallbackColor;

              final radius = radiusForIndex(index, lastItems.length);

              return CategoryCard(
                  title:
                      category?.name ??
                      goal?.name ??
                      wallet?.name ??
                      'Unknown category',
                  subtitle: isGoalTransaction
                      ? 'Goal'
                      : tx.note != null && tx.note!.isNotEmpty
                      ? tx.note
                      : null,
                  leading: Container(
                    height: AppSizing.heightS,
                    decoration: BoxDecoration(
                      color: resolvedColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppSizing.borderRadius8,
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Icon(
                        icon?.icon ?? Icons.category,
                        size: AppSizing.iconSizeM,
                        color: resolvedColor,
                      ),
                    ),
                  ),
                  trailing: AmountTextWidget(
                    amount: tx.amount,
                    type: tx.type,
                    showSignPrefix: true,
                    style: AppTextStyles.listTileTitle(context),
                  ),
                  radius: radius,
                );
            },
          ),
        ],
      ],
    );
  }

  List<TransactionModel> _filterHiddenTransactions(
    List<TransactionModel> transactions,
    Map<String, WalletModel> walletMap,
    Map<String, GoalModel> goalMap,
  ) {
    return transactions.where((tx) {
      final wallet = tx.walletId != null ? walletMap[tx.walletId] : null;
      final goal = tx.goalId != null ? goalMap[tx.goalId] : null;
      if (wallet != null && wallet.isHidden) return false;
      if (goal != null && goal.isHidden) return false;
      return true;
    }).toList();
  }

  List<CategoryModel> _extractCategories(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded s => s.categories,
      _ => const [],
    };
  }

  List<WalletModel> _extractWallets(WalletsState state) {
    return switch (state) {
      WalletsLoaded s => s.wallets,
      _ => const [],
    };
  }

  List<GoalModel> _extractGoals(GoalsState state) {
    return switch (state) {
      GoalsLoaded s => s.goalsModel.goals,
      _ => const [],
    };
  }

}
