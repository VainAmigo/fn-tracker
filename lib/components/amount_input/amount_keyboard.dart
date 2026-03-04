import 'package:fn_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Кастомная цифровая клавиатура для ввода суммы.
///
/// Сетка 4x3: 1-9, точка, 0, backspace.
/// Переиспользуемый компонент.
class AmountKeyboard extends StatelessWidget {
  const AmountKeyboard({super.key, required this.onKeyPressed});

  /// Вызывается при нажатии: '0'-'9', '.', или 'backspace'.
  final void Function(String key) onKeyPressed;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizing.spaceBtwElements),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.secondary, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSizing.spaceBtwElementsExtra,
            ),
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: row.indexOf(key) < row.length - 1
                          ? AppSizing.spaceBtwElementsExtra
                          : 0,
                    ),
                    child: _KeyButton(
                      keyLabel: key,
                      onPressed: () => onKeyPressed(key),
                      colorScheme: colorScheme,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.keyLabel,
    required this.onPressed,
    required this.colorScheme,
  });

  final String keyLabel;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

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
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
