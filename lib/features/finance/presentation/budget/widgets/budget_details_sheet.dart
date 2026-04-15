import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Bottom sheet с деталями бюджета, историей изменений и кнопками Edit/Delete.
class BudgetDetailsSheet extends StatelessWidget {
  const BudgetDetailsSheet({
    super.key,
    required this.budget,
    required this.totalForPeriod,
    required this.period,
    required this.history,
    required this.onEdit,
  });

  final BudgetModel budget;
  final double totalForPeriod;
  final DatePickerPeriod period;
  final List<BudgetHistoryEntry> history;
  final VoidCallback onEdit;

  static Future<void> show(
    BuildContext context, {
    required BudgetModel budget,
    required double totalForPeriod,
    required DatePickerPeriod period,
    required List<BudgetHistoryEntry> history,
    required VoidCallback onEdit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetDetailsSheet(
        budget: budget,
        totalForPeriod: totalForPeriod,
        period: period,
        history: history,
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
          _BudgetHistoryList(
            budgetId: budget.id,
            history: history,
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

class _BudgetHistoryList extends StatelessWidget {
  const _BudgetHistoryList({
    required this.budgetId,
    required this.history,
  });

  final String budgetId;
  final List<BudgetHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = List<BudgetHistoryEntry>.from(history)
      ..sort((a, b) => b.effectiveDayKey.compareTo(a.effectiveDayKey));

    return Column(
      children: [
        if (sorted.isEmpty)
          Text(
            context.l10n.noHistoryEntries,
            style: AppTextStyles.text14w400(
              context,
            ).copyWith(color: colorScheme.onSurface),
          )
        else
          ...sorted.map(
            (entry) => _HistoryEntryTile(
              entry: entry,
              onEdit: () => _showEditSheet(context, entry),
              onDelete: () => _confirmDelete(context, entry.id),
            ),
          ),
      ],
    );
  }

  void _showEditSheet(BuildContext context, BudgetHistoryEntry entry) {
    BudgetHistoryEntryFormSheet.show(
      context,
      entry: entry,
      title: context.l10n.editHistoryEntry,
      onSave: (amount, effectiveDayKey) {
        context.read<BudgetCubit>().updateBudgetHistoryEntry(
          budgetId: budgetId,
          entry: BudgetHistoryEntry(
            id: entry.id,
            amount: amount,
            effectiveDayKey: effectiveDayKey,
            createdAt: entry.createdAt,
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteHistoryEntry),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BudgetCubit>().deleteBudgetHistoryEntry(
        budgetId: budgetId,
        entryId: entryId,
      );
    }
  }
}

class _HistoryEntryTile extends StatelessWidget {
  const _HistoryEntryTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetHistoryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItems),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.defaultPadding,
          vertical: AppSizing.spaceBtwItems,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.effectiveDayKey,
                    style: AppTextStyles.text14w400(context),
                  ),
                  AmountTextWidget(amount: entry.amount),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit, size: 20, color: colorScheme.onSecondary),
              tooltip: context.l10n.edit,
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, size: 20, color: colorScheme.error),
              tooltip: context.l10n.delete,
            ),
          ],
        ),
      ),
    );
  }
}
