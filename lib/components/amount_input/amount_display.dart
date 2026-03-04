import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';

/// Отображение суммы по центру с символом валюты.
///
/// Символ валюты прижат к сумме в зависимости от [Currency.symbolPosition].
/// Переиспользуемый компонент.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currency,
    this.label = 'ENTER AMOUNT',
  });

  /// Сырое значение суммы (например "12586" или "12586.50").
  final String amount;

  /// Валюта для отображения символа и форматирования.
  final Currency currency;

  /// Подпись над полем (например "ВВЕДИТЕ СУММУ").
  final String label;

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
          Row(
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
                  amount,
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
          ),
        ],
      ),
    );
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
