import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

/// Bottom sheet для создания/редактирования записи в истории бюджета.
class BudgetHistoryEntryFormSheet extends StatefulWidget {
  const BudgetHistoryEntryFormSheet({
    super.key,
    this.entry,
    this.onSave,
    this.saveLabel,
    this.title,
  });

  final BudgetHistoryEntry? entry;
  final void Function(double amount, String effectiveDayKey)? onSave;
  final String? saveLabel;
  final String? title;

  static Future<void> show(
    BuildContext context, {
    BudgetHistoryEntry? entry,
    void Function(double amount, String effectiveDayKey)? onSave,
    String? saveLabel,
    String? title,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetHistoryEntryFormSheet(
        entry: entry,
        onSave: onSave,
        saveLabel: saveLabel ?? context.l10n.save,
        title: title,
      ),
    );
  }

  @override
  State<BudgetHistoryEntryFormSheet> createState() =>
      _BudgetHistoryEntryFormSheetState();
}

class _BudgetHistoryEntryFormSheetState
    extends State<BudgetHistoryEntryFormSheet> {
  late String _amountText;
  late DateTime _effectiveDate;

  @override
  void initState() {
    super.initState();
    _amountText = widget.entry != null
        ? AmountFormUtils.formatAmountForInput(widget.entry!.amount)
        : '';
    _effectiveDate = widget.entry != null
        ? DateTime.tryParse(widget.entry!.effectiveDayKey) ?? DateTime.now()
        : DateTime.now();
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
          if (widget.title != null) ...[
            Text(widget.title!, style: AppTextStyles.text20w600(context)),
            const SizedBox(height: AppSizing.spaceBtwItems),
          ],
          FormCardWidget(
            title: _effectiveDate.dayKey,
            subtitle: context.l10n.effectiveFrom,
            trailing: Icon(
              Icons.calendar_today,
              size: AppSizing.iconSizeS,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _effectiveDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null && mounted) {
                setState(() => _effectiveDate = picked);
              }
            },
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          AmountInputWidget(
            enableCalculator: true,
            initialAmount: _amountText,
            currency: currency,
            onAmountChanged: (amount) => setState(() => _amountText = amount),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PrimaryButton(
            text: widget.saveLabel ?? context.l10n.save,
            onPressed: () {
              final parsed = AmountFormUtils.parseAmount(_amountText);
              if (parsed == null || parsed <= 0) return;
              widget.onSave?.call(parsed, _effectiveDate.dayKey);
              if (context.mounted) Navigator.of(context).pop();
            },
            size: PrimaryButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
