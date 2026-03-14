import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Модальное окно для ввода PIN/пароля (для доступа к скрытым кошелькам).
class PasswordFormModalSheet extends StatefulWidget {
  const PasswordFormModalSheet({
    super.key,
    this.title,
    this.subtitle,
    this.submitLabel = 'Открыть',
    this.isSetMode = false,
    this.confirmLabel = 'Подтвердить',
    required this.onSubmit,
  });

  final String? title;
  final String? subtitle;
  final String submitLabel;
  final bool isSetMode;
  final String confirmLabel;
  /// Возвращает true при успехе (модалка закроется), false при ошибке.
  final Future<bool> Function(String password) onSubmit;

  /// Показать sheet для ввода пароля.
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? subtitle,
    String submitLabel = 'Открыть',
    bool isSetMode = false,
    String confirmLabel = 'Подтвердить',
    required Future<bool> Function(String password) onSubmit,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<bool>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: PasswordFormModalSheet(
        title: title,
        subtitle: subtitle,
        submitLabel: submitLabel,
        isSetMode: isSetMode,
        confirmLabel: confirmLabel,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<PasswordFormModalSheet> createState() => _PasswordFormModalSheetState();
}

class _PasswordFormModalSheetState extends State<PasswordFormModalSheet> {
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordVisibilityNotifier = PasswordVisibilityNotifier();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    _passwordVisibilityNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _controller.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorText = 'Введите PIN');
      return;
    }
    if (widget.isSetMode) {
      final confirm = _confirmController.text.trim();
      if (confirm != pin) {
        setState(() => _errorText = 'PIN не совпадает');
        return;
      }
    }
    setState(() => _errorText = null);
    final success = await widget.onSubmit(pin);
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
            Text(
              widget.title!,
              style: AppTextStyles.text20w600(context),
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
          ],
          if (widget.subtitle != null) ...[
            Text(
              widget.subtitle!,
              style: AppTextStyles.text16w400(context),
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
          ],
          PasswordTextField(
            controller: _controller,
            passwordVisibilityNotifier: _passwordVisibilityNotifier,
            label: 'PIN',
            onChanged: (_) => setState(() => _errorText = null),
          ),
          if (widget.isSetMode) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            PasswordTextField(
              controller: _confirmController,
              passwordVisibilityNotifier: _passwordVisibilityNotifier,
              label: 'Подтвердите PIN',
              onChanged: (_) => setState(() => _errorText = null),
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
          PrimaryButton(
            text: widget.isSetMode ? widget.confirmLabel : widget.submitLabel,
            onPressed: () => _submit(),
            size: PrimaryButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
