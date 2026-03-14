import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Модальное окно для смены PIN скрытых кошельков.
/// Использует цифровую клавиатуру вместо текстового поля.
class ChangePinFormModalSheet extends StatefulWidget {
  const ChangePinFormModalSheet({
    super.key,
    this.title,
    required this.onSubmit,
  });

  final String? title;
  final Future<bool> Function(String currentPin, String newPin) onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    String? title,
    required Future<bool> Function(String currentPin, String newPin) onSubmit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<bool>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: ChangePinFormModalSheet(
        title: title,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ChangePinFormModalSheet> createState() =>
      _ChangePinFormModalSheetState();
}

class _ChangePinFormModalSheetState extends State<ChangePinFormModalSheet> {
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  int _focusedField = 0;
  String? _errorText;

  void _onKeyPressed(String key) {
    setState(() {
      _errorText = null;
      if (key == 'backspace') {
        if (_focusedField == 0 && _currentPin.isNotEmpty) {
          _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        } else if (_focusedField == 1 && _newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        } else if (_focusedField == 2 && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else if (key != '.') {
        if (_focusedField == 0) {
          _currentPin += key;
        } else if (_focusedField == 1) {
          _newPin += key;
        } else {
          _confirmPin += key;
        }
      }
    });
  }

  Future<void> _submit() async {
    if (_currentPin.isEmpty) {
      setState(() => _errorText = 'Введите текущий PIN');
      return;
    }
    if (_newPin.isEmpty) {
      setState(() => _errorText = 'Введите новый PIN');
      return;
    }
    if (_newPin != _confirmPin) {
      setState(() => _errorText = 'Новый PIN не совпадает');
      return;
    }
    if (_currentPin == _newPin) {
      setState(() => _errorText = 'Новый PIN должен отличаться');
      return;
    }

    setState(() => _errorText = null);
    final success = await widget.onSubmit(_currentPin, _newPin);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errorText = 'Неверный текущий PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _PinDisplay(
            label: 'Текущий PIN',
            value: _currentPin,
            isFocused: _focusedField == 0,
            onTap: () => setState(() => _focusedField = 0),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _PinDisplay(
            label: 'Новый PIN',
            value: _newPin,
            isFocused: _focusedField == 1,
            onTap: () => setState(() => _focusedField = 1),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _PinDisplay(
            label: 'Подтвердите новый PIN',
            value: _confirmPin,
            isFocused: _focusedField == 2,
            onTap: () => setState(() => _focusedField = 2),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            Text(
              _errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: AppSizing.spaceBtwElements),
          AmountKeyboard(onKeyPressed: _onKeyPressed),
          const SizedBox(height: AppSizing.spaceBtwElements),
          PrimaryButton(
            text: 'Сменить PIN',
            onPressed: () => _submit(),
            size: PrimaryButtonSize.medium,
          ),
        ],
      ),
    );
  }
}

class _PinDisplay extends StatelessWidget {
  const _PinDisplay({
    required this.label,
    required this.value,
    required this.isFocused,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isFocused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.spaceBtwElements,
          vertical: AppSizing.spaceBtwItemsExtra,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
          border: Border.all(
            color: isFocused ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.text14w400(
                context,
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            Text(
              value.isEmpty ? '—' : '•' * value.length,
              style: AppTextStyles.text20w600(context).copyWith(
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
