import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Модальное окно для смены PIN скрытых кошельков.
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
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordVisibilityNotifier = PasswordVisibilityNotifier();
  String? _errorText;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _passwordVisibilityNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text.trim();
    final newPin = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty) {
      setState(() => _errorText = 'Введите текущий PIN');
      return;
    }
    if (newPin.isEmpty) {
      setState(() => _errorText = 'Введите новый PIN');
      return;
    }
    if (newPin != confirm) {
      setState(() => _errorText = 'Новый PIN не совпадает');
      return;
    }
    if (current == newPin) {
      setState(() => _errorText = 'Новый PIN должен отличаться');
      return;
    }

    setState(() => _errorText = null);
    final success = await widget.onSubmit(current, newPin);
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
          PasswordTextField(
            controller: _currentController,
            passwordVisibilityNotifier: _passwordVisibilityNotifier,
            label: 'Текущий PIN',
            onChanged: (_) => setState(() => _errorText = null),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PasswordTextField(
            controller: _newController,
            passwordVisibilityNotifier: _passwordVisibilityNotifier,
            label: 'Новый PIN',
            onChanged: (_) => setState(() => _errorText = null),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          PasswordTextField(
            controller: _confirmController,
            passwordVisibilityNotifier: _passwordVisibilityNotifier,
            label: 'Подтвердите новый PIN',
            onChanged: (_) => setState(() => _errorText = null),
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
