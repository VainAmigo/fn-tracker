import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class CategoriesDetailModalSheetWidget extends StatelessWidget {
  const CategoriesDetailModalSheetWidget({
    super.key,
    required this.category,
    required this.onEdit,
  });

  final CategoryModel category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = context.watch<CurrencyProvider>().currency;
    final shade = findShadeById(category.colorId);
    final icon = findIconById(category.iconId);
    final color = shade?.color ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: context.l10n.categoryDetails,
            action: PrimaryButton(
              text: context.l10n.edit,
              onPressed: onEdit,
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Builder(
            builder: (context) {
              final limitLabel = BudgetDisplayUtils.formatCategoryLimit(
                category,
                currencySymbol: currency.symbol,
                formatAmount: (a) => AmountFormatter.format(a),
              );
              return CategoryCard(
                title: category.name,
                subtitle: limitLabel != null
                    ? AmountFormatter.formatWithDots(
                        context.l10n.limit,
                        limitLabel,
                      )
                    : null,
                leading: Container(
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
              );
            },
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          PrimaryButton(
            text: context.l10n.history,
            icon: Icons.history,
            size: PrimaryButtonSize.xSmall,
            paddingStyle: PrimaryButtonPaddingStyle.slim,
            rounded: true,
            backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
            foregroundColor: colorScheme.tertiary,
            onPressed: () => Navigator.of(context).pushNamed(
              AppRouter.transactionsById,
              arguments: {
                'idType': TransactionIdType.category,
                'id': category.categoryId,
              },
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSizing.spaceBtwItemsExtra,
            children: [
              BlocListener<CategoriesCubit, CategoriesState>(
                listenWhen: (prev, curr) =>
                    curr is CategoriesLoaded || curr is CategoriesError,
                listener: (context, state) {
                  if (state is CategoriesLoaded) {
                    Navigator.of(context).pop();
                  }
                  if (state is CategoriesError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: PrimaryButton(
                  text: context.l10n.delete,
                  icon: Icons.delete,
                  iconOnly: true,
                  fullWidth: false,
                  size: PrimaryButtonSize.large,
                  paddingStyle: PrimaryButtonPaddingStyle.slim,
                  rounded: true,
                  onPressed: () async {
                    final result = await showDeleteEntityDialog(
                      context,
                      title: context.l10n.deleteCategoryTitle,
                      message:
                          '${context.l10n.deleteCategoryMessage} «${category.name}»? ${context.l10n.deleteCategoryMessageHint}',
                    );
                    if (!context.mounted ||
                        result == null ||
                        result == DeleteEntityResult.cancel) {
                      return;
                    }
                    context.read<CategoriesCubit>().deleteCategory(
                      categoryId: category.categoryId,
                      deleteTransactions:
                          result == DeleteEntityResult.deleteFull,
                    );
                  },
                ),
              ),
              Flexible(
                child: PrimaryButton(
                  text: context.l10n.addTransaction,
                  size: PrimaryButtonSize.large,
                  rounded: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pushNamed(AppRouter.addTransaction, arguments: category);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}
