import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Bottom sheet: edit / delete бюджета.
class BudgetDetailsSheet extends StatelessWidget {
  const BudgetDetailsSheet({
    super.key,
    required this.budget,
    required this.budgetAmount,
    required this.onEdit,
  });

  final BudgetModel budget;
  final double budgetAmount;
  final VoidCallback onEdit;

  static Future<void> show(
    BuildContext context, {
    required BudgetModel budget,
    required double budgetAmount,
    required VoidCallback onEdit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetDetailsSheet(
        budget: budget,
        budgetAmount: budgetAmount,
        onEdit: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(title: context.l10n.budgetDetails),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Text(
            context.l10n.monthlyBudget,
            style: AppTextStyles.text14w400(
              context,
            ).copyWith(color: colorScheme.onSecondary),
          ),
          AmountTextWidget(
            amount: budgetAmount,
            style: AppTextStyles.text20w600(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSizing.spaceBtwItemsExtra,
            children: [
              BlocListener<BudgetCubit, BudgetState>(
                listenWhen: (prev, curr) =>
                    curr is BudgetStatsLoaded || curr is BudgetError,
                listener: (context, state) {
                  if (state is BudgetStatsLoaded) {
                    Navigator.of(context).pop();
                  }
                  if (state is BudgetError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error)));
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
                  backgroundColor: colorScheme.error.withValues(alpha: 0.3),
                  foregroundColor: colorScheme.error,
                  onPressed: () async {
                    final result = await showDeleteEntityDialog(
                      context,
                      title: context.l10n.deleteBudget,
                      message: context.l10n.deleteBudgetConfirmation,
                    );
                    if (!context.mounted ||
                        result == null ||
                        result == DeleteEntityResult.cancel) {
                      return;
                    }
                    context.read<BudgetCubit>().deleteBudget(budget.id);
                  },
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  text: context.l10n.editBudget,
                  size: PrimaryButtonSize.large,
                  rounded: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onEdit();
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
