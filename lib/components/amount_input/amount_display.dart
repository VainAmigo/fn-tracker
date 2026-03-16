import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';

/// Отображение суммы по центру с символом валюты.
///
/// Символ валюты прижат к сумме в зависимости от [Currency.symbolPosition].
/// При [expression] и [computedResult] — режим калькулятора: выражение сверху, результат снизу.
/// Переиспользуемый компонент.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currency,
    this.label = 'ENTER AMOUNT',
    this.expression,
    this.computedResult,
  });

  /// Сырое значение суммы (например "12586" или "12586.50").
  /// В режиме калькулятора — выражение (например "65*44").
  final String amount;

  /// Валюта для отображения символа и форматирования.
  final Currency currency;

  /// Подпись над полем (например "ВВЕДИТЕ СУММУ").
  final String label;

  /// Выражение для отображения в режиме калькулятора (например "65*44").
  final String? expression;

  /// Вычисленный результат для отображения под выражением.
  final String? computedResult;

  bool get _isCalculatorMode => expression != null && expression!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isRight = _isSymbolOnRight(currency.symbolPosition);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizing.spaceBtwSections),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.amountDisplayTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          if (_isCalculatorMode) ...[
            _buildExpressionRow(context, colorScheme),
            _buildResultRow(
              context,
              colorScheme,
              isRight,
              computedResult ?? '',
            ),
          ] else
            _buildAmountRow(context, colorScheme, isRight, amount),
        ],
      ),
    );
  }

  Widget _buildExpressionRow(BuildContext context, ColorScheme colorScheme) {
    return Text(
      _formatExpression(expression!),
      style: AppTextStyles.amountDisplayTitle(
        context,
      ).copyWith(fontSize: 20, color: colorScheme.onSecondary),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    ColorScheme colorScheme,
    bool isRight,
    String resultText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (!isRight) ...[
          _buildSymbol(context, colorScheme),
          const SizedBox(width: AppSizing.spaceBtwItemsExtra),
        ],
        Flexible(
          child: Text(
            resultText.isEmpty ? '0' : resultText,
            style: AppTextStyles.amountDisplayAmount(context),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (isRight) ...[
          const SizedBox(width: AppSizing.spaceBtwItemsExtra),
          _buildSymbol(context, colorScheme),
        ],
      ],
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    ColorScheme colorScheme,
    bool isRight,
    String displayAmount,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (!isRight) ...[
          _buildSymbol(context, colorScheme),
          const SizedBox(width: AppSizing.spaceBtwItemsExtra),
        ],
        Flexible(
          child: Text(
            displayAmount,
            style: AppTextStyles.amountDisplayAmount(context),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (isRight) ...[
          const SizedBox(width: AppSizing.spaceBtwItemsExtra),
          _buildSymbol(context, colorScheme),
        ],
      ],
    );
  }

  String _formatExpression(String expr) {
    return expr.replaceAll('*', '×').replaceAll('/', '÷').replaceAll(',', '.');
  }

  Widget _buildSymbol(BuildContext context, ColorScheme colorScheme) {
    return Text(
      currency.symbol,
      style: AppTextStyles.amountDisplayAmount(context).copyWith(
        color: colorScheme.onSecondary,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  bool _isSymbolOnRight(SymbolPosition position) {
    return position == SymbolPosition.right ||
        position == SymbolPosition.rightWithSpace;
  }
}
