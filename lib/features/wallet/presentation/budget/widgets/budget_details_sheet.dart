import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Bottom sheet с деталями бюджета и кнопками Edit/Delete.
class BudgetDetailsSheet extends StatelessWidget {
  const BudgetDetailsSheet({
    super.key,
    required this.budget,
    required this.totalForPeriod,
    required this.currency,
    required this.period,
    required this.onEdit,
  });

  final BudgetModel budget;
  final double totalForPeriod;
  final Currency currency;
  final DatePickerPeriod period;
  final VoidCallback onEdit;

  static Future<void> show(
    BuildContext context, {
    required BudgetModel budget,
    required double totalForPeriod,
    required Currency currency,
    required DatePickerPeriod period,
    required VoidCallback onEdit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetDetailsSheet(
        budget: budget,
        totalForPeriod: totalForPeriod,
        currency: currency,
        period: period,
        onEdit: onEdit,
      ),
    );
  }

  static String _budgetTypeLabel(BudgetType type) {
    return switch (type) {
      BudgetType.yearly => 'Yearly',
      BudgetType.monthly => 'Monthly',
      BudgetType.weekly => 'Weekly',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = CurrencyFormatter(currency);
    final budgetForPeriod =
        BudgetDisplayUtils.budgetForDisplayPeriod(budget, period);

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: 'Budget details',
            action: PrimaryButton(
              text: 'Edit',
              onPressed: () {
                Navigator.of(context).pop();
                onEdit();
              },
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          _InfoRow(
            label: 'Type',
            value: _budgetTypeLabel(budget.type),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _InfoRow(
            label: 'Budget amount',
            value: formatter.format(budget.amount),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _InfoRow(
            label: 'Budget for period',
            value: formatter.format(budgetForPeriod),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _InfoRow(
            label: 'Spent',
            value: formatter.format(totalForPeriod),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                child: PrimaryButton(
                  text: 'Delete',
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
                      title: 'Delete budget?',
                      message: 'Are you sure you want to delete this budget?',
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
                  text: 'Edit',
                  icon: Icons.edit,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.text14w400(context)),
        Text(
          value,
          style: AppTextStyles.text14w400(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
