import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Модальное окно для ввода PIN (для доступа к скрытым кошелькам).
/// Использует цифровую клавиатуру вместо текстового поля.
class PasswordFormModalSheet extends StatefulWidget {
  const PasswordFormModalSheet({
    super.key,
    this.title,
    this.subtitle,
    this.submitLabel,
    this.isSetMode = false,
    this.confirmLabel,
    required this.onSubmit,
  });

  final String? title;
  final String? subtitle;
  final String? submitLabel;
  final bool isSetMode;
  final String? confirmLabel;

  /// Возвращает true при успехе (модалка закроется), false при ошибке.
  final Future<bool> Function(String password) onSubmit;

  /// Показать sheet для ввода пароля.
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? subtitle,
    String? submitLabel,
    bool isSetMode = false,
    String? confirmLabel,
    required Future<bool> Function(String password) onSubmit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<bool>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: PasswordFormModalSheet(
        title: title,
        subtitle: subtitle,
        submitLabel: submitLabel ?? context.l10n.open,
        isSetMode: isSetMode,
        confirmLabel: confirmLabel ?? context.l10n.confirm,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<PasswordFormModalSheet> createState() => _PasswordFormModalSheetState();
}

class _PasswordFormModalSheetState extends State<PasswordFormModalSheet> {
  String _pin = '';
  String _confirmPin = '';
  int _focusedField = 0;
  String? _errorText;

  void _onKeyPressed(String key) {
    setState(() {
      _errorText = null;
      if (key == 'backspace') {
        if (_focusedField == 0) {
          if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
        } else {
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
        }
      } else if (key != '.') {
        if (_focusedField == 0) {
          _pin += key;
        } else {
          _confirmPin += key;
        }
      }
    });
  }

  Future<void> _submit() async {
    if (_pin.isEmpty) {
      setState(() => _errorText = context.l10n.enterPin);
      return;
    }
    if (widget.isSetMode) {
      if (_confirmPin != _pin) {
        setState(() => _errorText = context.l10n.pinDoesNotMatch);
        return;
      }
    }
    setState(() => _errorText = null);
    final success = await widget.onSubmit(_pin);
    if (!mounted) return;
    if (success) Navigator.of(context).pop(true);
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
            Text(widget.title!, style: AppTextStyles.text20w600(context)),
            const SizedBox(height: AppSizing.spaceBtwItems),
          ],
          if (widget.subtitle != null) ...[
            Text(widget.subtitle!, style: AppTextStyles.text16w400(context)),
            const SizedBox(height: AppSizing.spaceBtwItems),
          ],
          _PinDisplay(
            label: context.l10n.pin,
            value: _pin,
            isFocused: _focusedField == 0,
            onTap: () => setState(() => _focusedField = 0),
          ),
          if (widget.isSetMode) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            _PinDisplay(
              label: context.l10n.confirmPin,
              value: _confirmPin,
              isFocused: _focusedField == 1,
              onTap: () => setState(() => _focusedField = 1),
            ),
          ],
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
            text: widget.isSetMode
                ? widget.confirmLabel ?? context.l10n.confirm
                : widget.submitLabel ?? context.l10n.open,
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
              style: AppTextStyles.text20w600(
                context,
              ).copyWith(letterSpacing: 4),
            ),
          ],
        ),
      ),
    );
  }
}
