import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/utils/expression_evaluator.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

/// Bottom sheet для создания/редактирования бюджета с выбором типа.
class BudgetFormModalSheet extends StatefulWidget {
  const BudgetFormModalSheet({
    super.key,
    this.initialAmount,
    this.initialType = BudgetType.monthly,
    this.onSave,
    this.saveLabel = 'Save',
    this.title,
  });

  final double? initialAmount;
  final BudgetType initialType;
  final void Function(double amount, BudgetType type)? onSave;
  final String saveLabel;
  final String? title;

  /// Показать sheet для создания/редактирования бюджета.
  static Future<void> show(
    BuildContext context, {
    double? initialAmount,
    BudgetType initialType = BudgetType.monthly,
    void Function(double amount, BudgetType type)? onSave,
    String saveLabel = 'Save',
    String? title,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: BudgetFormModalSheet(
        initialAmount: initialAmount,
        initialType: initialType,
        onSave: onSave,
        saveLabel: saveLabel,
        title: title,
      ),
    );
  }

  static String _formatAmountForInput(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.truncate().toString();
    }
    return amount.toString();
  }

  @override
  State<BudgetFormModalSheet> createState() => _BudgetFormModalSheetState();
}

class _BudgetFormModalSheetState extends State<BudgetFormModalSheet> {
  late String _amountText;
  late BudgetType _selectedType;

  /// Парсит сумму: поддерживает числа и выражения (100+50, 10*2).
  double? _parseAmount(String text) {
    var t = text.trim();
    if (t.isEmpty) return null;
    const operators = ['+', '-', '*', '/'];
    while (t.length > 1 && operators.contains(t[t.length - 1])) {
      t = t.substring(0, t.length - 1).trim();
    }
    if (t.isEmpty) return null;
    if (ExpressionEvaluator.hasOperator(t)) {
      final evaluated = ExpressionEvaluator.evaluate(t);
      if (evaluated != null && evaluated > 0) return evaluated;
    }
    final parsed = double.tryParse(t.replaceAll(',', '.'));
    return parsed != null && parsed > 0 ? parsed : null;
  }

  static const _typeSegments = [
    SegmentItem<BudgetType>(
      value: BudgetType.yearly,
      label: 'Yearly',
    ),
    SegmentItem<BudgetType>(
      value: BudgetType.monthly,
      label: 'Monthly',
    ),
    SegmentItem<BudgetType>(
      value: BudgetType.weekly,
      label: 'Weekly',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _amountText = widget.initialAmount != null
        ? BudgetFormModalSheet._formatAmountForInput(widget.initialAmount!)
        : '';
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyProvider>().currency;

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
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: AppTextStyles.text20w600(context),
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
          ],
          SegmentedControl<BudgetType>(
            segments: _typeSegments,
            selectedValue: _selectedType,
            onChanged: (type) => setState(() => _selectedType = type),
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
            text: widget.saveLabel,
            onPressed: () {
              final parsed = _parseAmount(_amountText);
              if (parsed == null || parsed <= 0) return;
              widget.onSave?.call(parsed, _selectedType);
              if (context.mounted) Navigator.of(context).pop();
            },
            size: PrimaryButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
