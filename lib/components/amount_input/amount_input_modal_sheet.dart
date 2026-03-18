import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/utils/expression_evaluator.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:provider/provider.dart';

/// Универсальный bottom sheet для ввода суммы.
/// Используется для бюджета, запланированных платежей и других сценариев.
class AmountFormModalSheet extends StatefulWidget {
  const AmountFormModalSheet({
    super.key,
    this.initialAmount,
    this.onSave,
    this.saveLabel = 'Save',
    this.title,
    this.enableCalculator = false,
  });

  final double? initialAmount;
  final void Function(double amount)? onSave;
  final String saveLabel;
  final String? title;
  final bool enableCalculator;

  /// Показать sheet для ввода/редактирования суммы.
  ///
  /// [initialAmount] — начальная сумма (для режима редактирования).
  /// [onSave] — вызывается с введённой суммой при нажатии Save.
  static Future<void> show(
    BuildContext context, {
    double? initialAmount,
    void Function(double amount)? onSave,
    String saveLabel = 'Save',
    String? title,
    bool enableCalculator = false,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: AmountFormModalSheet(
        initialAmount: initialAmount,
        onSave: onSave,
        saveLabel: saveLabel,
        title: title,
        enableCalculator: enableCalculator,
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
  State<AmountFormModalSheet> createState() => _AmountFormModalSheetState();
}

class _AmountFormModalSheetState extends State<AmountFormModalSheet> {
  late String _amountText;

  /// Парсит сумму: поддерживает числа и выражения (100+50, 10*2) при enableCalculator.
  double? _parseAmount(String text) {
    var t = text.trim();
    if (t.isEmpty) return null;
    // Убираем завершающие операторы (например "150+" после вычисления)
    const operators = ['+', '-', '*', '/'];
    while (t.length > 1 && operators.contains(t[t.length - 1])) {
      t = t.substring(0, t.length - 1).trim();
    }
    if (t.isEmpty) return null;
    if (widget.enableCalculator && ExpressionEvaluator.hasOperator(t)) {
      final evaluated = ExpressionEvaluator.evaluate(t);
      if (evaluated != null && evaluated > 0) return evaluated;
    }
    final parsed = double.tryParse(t.replaceAll(',', '.'));
    return parsed != null && parsed > 0 ? parsed : null;
  }

  @override
  void initState() {
    super.initState();
    _amountText = widget.initialAmount != null
        ? AmountFormModalSheet._formatAmountForInput(widget.initialAmount!)
        : '';
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
          AmountInputWidget(
            enableCalculator: widget.enableCalculator,
            initialAmount: _amountText,
            currency: currency,
            onAmountChanged: (amount) => setState(() => _amountText = amount),
          ),
          PrimaryButton(
            text: widget.saveLabel,
            onPressed: () {
              final parsed = _parseAmount(_amountText);
              if (parsed == null || parsed <= 0) return;
              widget.onSave?.call(parsed);
              if (context.mounted) Navigator.of(context).pop();
            },
            size: PrimaryButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
