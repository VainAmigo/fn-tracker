import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

import 'budget_effective_date_selector.dart';
import 'budget_info_modal_sheet.dart';

/// Bottom sheet для создания/редактирования бюджета с выбором типа.
class BudgetFormModalSheet extends StatefulWidget {
  const BudgetFormModalSheet({
    super.key,
    this.initialAmount,
    this.isEdit = false,
    this.onSave,
    this.saveLabel = 'Save',
    this.title,
  });

  final double? initialAmount;
  final bool isEdit;
  final void Function(
    double amount, {
    String? effectiveDayKey,
    bool replaceAll,
  })?
  onSave;
  final String saveLabel;
  final String? title;

  /// Показать sheet для создания/редактирования бюджета.
  static Future<void> show(
    BuildContext context, {
    double? initialAmount,
    bool isEdit = false,
    void Function(double amount, {String? effectiveDayKey, bool replaceAll})?
    onSave,
    String saveLabel = 'Save',
    String? title,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetFormModalSheet(
        initialAmount: initialAmount,
        isEdit: isEdit,
        onSave: onSave,
        saveLabel: saveLabel,
        title: title,
      ),
    );
  }

  @override
  State<BudgetFormModalSheet> createState() => _BudgetFormModalSheetState();
}

class _BudgetFormModalSheetState extends State<BudgetFormModalSheet> {
  late String _amountText;
  BudgetEffectiveDateMode _effectiveMode = BudgetEffectiveDateMode.replaceAll;
  DateTime _effectiveDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountText = widget.initialAmount != null
        ? AmountFormUtils.formatAmountForInput(widget.initialAmount!)
        : '';
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
            title: widget.title ?? 'Budget',
            action: widget.isEdit
                ? PrimaryButton(
                    text: 'info',
                    onPressed: () => BudgetInfoModalSheet.show(context),
                    size: PrimaryButtonSize.xSmall,
                    fullWidth: false,
                    rounded: true,
                    iconOnly: true,
                    icon: Icons.info_outline,
                  )
                : null,
          ),
          if (widget.isEdit) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            BudgetEffectiveDateSelector(
              mode: _effectiveMode,
              effectiveDate: _effectiveDate,
              onModeChanged: (m) => setState(() => _effectiveMode = m),
              onDateChanged: (d) {
                if (mounted) setState(() => _effectiveDate = d);
              },
            ),
          ],
          const SizedBox(height: AppSizing.spaceBtwItems),
          AmountInputWidget(
            enableCalculator: true,
            initialAmount: _amountText,
            currency: currency,
            onAmountChanged: (amount) => setState(() => _amountText = amount),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: widget.saveLabel,
            onPressed: () {
              final parsed = AmountFormUtils.parseAmount(_amountText);
              if (parsed == null || parsed <= 0) return;
              final replaceAll =
                  _effectiveMode == BudgetEffectiveDateMode.replaceAll;
              final effectiveDayKey =
                  _effectiveMode == BudgetEffectiveDateMode.fromDate
                  ? _effectiveDate.dayKey
                  : null;
              widget.onSave?.call(
                parsed,
                effectiveDayKey: effectiveDayKey,
                replaceAll: replaceAll,
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
