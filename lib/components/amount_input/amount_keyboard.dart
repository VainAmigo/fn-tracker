import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';

/// Кастомная цифровая клавиатура для ввода суммы.
///
/// Сетка 4x3: 1-9, точка, 0, backspace.
/// При [showOperators] = true добавляется правый столбец с операторами + - * /.
/// Переиспользуемый компонент.
class AmountKeyboard extends StatelessWidget {
  const AmountKeyboard({
    super.key,
    required this.onKeyPressed,
    this.showOperators = false,
  });

  /// Вызывается при нажатии: '0'-'9', '.', 'backspace', или '+', '-', '*', '/' при showOperators.
  final void Function(String key) onKeyPressed;

  /// Показывать ли правый столбец с математическими операторами.
  final bool showOperators;

  static const _baseKeys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', 'backspace'],
  ];

  static const _operatorColumn = ['+', '-', '*', '/'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizing.spaceBtwElements),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.secondary, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_baseKeys.length, (rowIndex) {
          final row = _baseKeys[rowIndex];
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSizing.spaceBtwItemsExtra,
            ),
            child: Row(
              children: [
                ...row.asMap().entries.map((entry) {
                  final key = entry.value;
                  final isLastInRow = entry.key == row.length - 1;
                  final hasRightPadding = !isLastInRow || showOperators;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: hasRightPadding
                            ? AppSizing.spaceBtwItemsExtra
                            : 0,
                      ),
                      child: _KeyButton(
                        keyLabel: key,
                        onPressed: () => onKeyPressed(key),
                        colorScheme: colorScheme,
                      ),
                    ),
                  );
                }),
                if (showOperators)
                  Expanded(
                    child: _KeyButton(
                      keyLabel: _operatorColumn[rowIndex],
                      onPressed: () => onKeyPressed(_operatorColumn[rowIndex]),
                      colorScheme: colorScheme,
                      isOperator: true,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.keyLabel,
    required this.onPressed,
    required this.colorScheme,
    this.isOperator = false,
  });

  final String keyLabel;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final bool isOperator;

  @override
  Widget build(BuildContext context) {
    final isBackspace = keyLabel == 'backspace';

    return Material(
      color: colorScheme.secondary,
      borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
        child: Container(
          height: AppSizing.heightM,
          alignment: Alignment.center,
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  color: colorScheme.onSecondary,
                  size: AppSizing.iconSizeM,
                )
              : Text(
                  keyLabel,
                  style: TextStyle(
                    fontSize: AppSizing.fontSizeL,
                    fontWeight: FontWeight.w600,
                    color: isOperator
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
