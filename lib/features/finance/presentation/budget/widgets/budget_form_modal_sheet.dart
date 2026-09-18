import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

enum BudgetStartMonth { thisMonth, nextMonth }

/// Bottom sheet для создания/редактирования месячного бюджета.
class BudgetFormModalSheet extends StatefulWidget {
  const BudgetFormModalSheet({
    super.key,
    this.initialAmount,
    this.isEdit = false,
    this.onSave,
    this.saveLabel,
    this.title,
    this.categories = const [],
  });

  final double? initialAmount;
  final bool isEdit;
  final void Function(double amount, {required String startMonthKey})? onSave;
  final String? saveLabel;
  final String? title;
  final List<CategoryModel> categories;

  static Future<void> show(
    BuildContext context, {
    double? initialAmount,
    bool isEdit = false,
    void Function(double amount, {required String startMonthKey})? onSave,
    String? saveLabel,
    String? title,
    List<CategoryModel> categories = const [],
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetFormModalSheet(
        initialAmount: initialAmount,
        isEdit: isEdit,
        onSave: onSave,
        saveLabel: saveLabel ?? context.l10n.save,
        title: title,
        categories: categories,
      ),
    );
  }

  @override
  State<BudgetFormModalSheet> createState() => _BudgetFormModalSheetState();
}

class _BudgetFormModalSheetState extends State<BudgetFormModalSheet> {
  late String _amountText;
  BudgetStartMonth _startMonth = BudgetStartMonth.thisMonth;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountText = widget.initialAmount != null
        ? AmountFormUtils.formatAmountForInput(widget.initialAmount!)
        : '';
  }

  String _monthKeyFor(BudgetStartMonth start) {
    final now = DateTime.now();
    final date = start == BudgetStartMonth.thisMonth
        ? DateTime(now.year, now.month)
        : DateTime(now.year, now.month + 1);
    return date.periodKey;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyProvider>().currency;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizing.defaultPadding,
        AppSizing.defaultPadding,
        AppSizing.defaultPadding,
        AppSizing.bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModalSheetTitleWidget(
            title: widget.title ?? context.l10n.budget,
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          SegmentedControl<BudgetStartMonth>(
            segments: [
              SegmentItem(
                value: BudgetStartMonth.thisMonth,
                label: context.l10n.thisMonth,
              ),
              SegmentItem(
                value: BudgetStartMonth.nextMonth,
                label: context.l10n.nextMonth,
              ),
            ],
            selectedValue: _startMonth,
            onChanged: (m) => setState(() {
              _startMonth = m;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          Text(
            '${context.l10n.budgetStartsFrom}: ${_monthKeyFor(_startMonth)}',
            style: AppTextStyles.text12w400(context).copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          AmountInputWidget(
            enableCalculator: true,
            initialAmount: _amountText,
            currency: currency,
            onAmountChanged: (amount) => setState(() {
              _amountText = amount;
              _error = null;
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            Text(
              _error!,
              style: AppTextStyles.text12w400(context).copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: widget.saveLabel ?? context.l10n.save,
            onPressed: () {
              final parsed = AmountFormUtils.parseAmount(_amountText);
              if (parsed == null || parsed <= 0) return;
              final fixedTotal =
                  BudgetCalculator.fixedLimitsTotal(widget.categories);
              if (fixedTotal > parsed) {
                setState(() => _error = context.l10n.fixedLimitsExceedBudget);
                return;
              }
              widget.onSave?.call(
                parsed,
                startMonthKey: _monthKeyFor(_startMonth),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            size: PrimaryButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
