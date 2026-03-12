import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Bottom sheet с деталями транзакции: сумма, имя, описание, кошелёк, дата.
class TransactionDetailsSheet extends StatelessWidget {
  const TransactionDetailsSheet({super.key, required this.transaction});

  final TransactionModel transaction;

  static Future<void> show(
    BuildContext context, {
    required TransactionModel transaction,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: TransactionDetailsSheet(transaction: transaction),
    );
  }

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

    final isGoalTransaction =
        transaction.categoryId == null || transaction.categoryId!.isEmpty;
    final goal = isGoalTransaction && transaction.goalId != null
        ? goalMap[transaction.goalId]
        : null;
    final category = !isGoalTransaction
        ? categoryMap[transaction.categoryId]
        : null;
    final wallet = transaction.walletId != null
        ? walletMap[transaction.walletId]
        : null;

    final shade = category != null
        ? findShadeById(category.colorId)
        : goal != null
        ? findShadeById(goal.colorId)
        : null;
    final icon = category != null
        ? findIconById(category.iconId)
        : goal != null
        ? findIconById(goal.iconId)
        : null;
    final color = shade?.color ?? Colors.grey;

    final name = category?.name ?? goal?.name ?? transaction.categoryId ?? '—';
    final typeLabel = transaction.type == TransactionType.income
        ? 'Income'
        : 'Expense';

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: AmountTextWidget(
              amount: transaction.amount,
              type: transaction.type,
              showSignPrefix: true,
              style: AppTextStyles.amountDisplayAmount(context),
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          Center(
            child: Text(typeLabel, style: AppTextStyles.text14w400(context)),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          CategoryCard(
            subtitle: 'Category',
            title: name,
            leading: _detailLeading(
              context,
              icon: icon?.icon ?? Icons.category,
              color: color,
            ),
            radius: CardRadius.first,
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: AppSizing.spaceBtwItemsExtra),
            CategoryCard(
              subtitle: 'Description',
              title: transaction.note ?? '—',
              leading: _detailLeading(
                context,
                icon: Icons.note_rounded,
                color: null,
              ),
              radius: CardRadius.middle,
            ),
          ],
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          CategoryCard(
            subtitle: transaction.type == TransactionType.income
                ? 'To'
                : 'From',
            title: wallet?.name ?? '—',
            leading: _detailLeading(
              context,
              icon: wallet != null
                  ? (findIconById(wallet.iconId)?.icon ??
                        Icons.account_balance_wallet_rounded)
                  : Icons.account_balance_wallet_rounded,
              color: wallet != null
                  ? findShadeById(wallet.colorId)?.color
                  : null,
            ),
            radius: CardRadius.middle,
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          CategoryCard(
            subtitle: 'Date',
            title: transaction.date.formatDayMonthYearUpper,
            leading: _detailLeading(
              context,
              icon: Icons.calendar_today_rounded,
              color: null,
            ),
            radius: CardRadius.last,
          ),
        ],
      ),
    );
  }

  List<CategoryModel> _extractCategories(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded s => s.categories,
      _ => const [],
    };
  }

  List<GoalModel> _extractGoals(GoalsState state) {
    return switch (state) {
      GoalsLoaded s => s.goalsModel.goals,
      _ => const [],
    };
  }

  List<WalletModel> _extractWallets(WalletsState state) {
    return switch (state) {
      WalletsLoaded s => s.wallets,
      _ => const [],
    };
  }
}

Widget _detailLeading(
  BuildContext context, {
  required IconData icon,
  Color? color,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final iconColor = color ?? colorScheme.onSurfaceVariant;

  return Container(
    height: AppSizing.heightS,
    width: AppSizing.heightS,
    decoration: BoxDecoration(
      color: (color ?? colorScheme.onSurfaceVariant).withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
    ),
    child: Icon(icon, size: AppSizing.iconSizeM, color: iconColor),
  );
}
