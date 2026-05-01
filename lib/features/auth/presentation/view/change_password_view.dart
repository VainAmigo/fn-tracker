import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _currentVisibility = PasswordVisibilityNotifier();
  final _newVisibility = PasswordVisibilityNotifier();
  final _confirmVisibility = PasswordVisibilityNotifier();
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentVisibility.dispose();
    _newVisibility.dispose();
    _confirmVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.changePassword),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizing.spaceBtwSections),
                  PasswordTextField(
                    controller: _currentController,
                    label: context.l10n.currentPassword,
                    passwordVisibilityNotifier: _currentVisibility,
                    validator: (value) =>
                        AuthValidationUtils.currentPasswordForChange(
                      value,
                      context,
                    ),
                  ),
                  PasswordTextField(
                    controller: _newController,
                    label: context.l10n.newPassword,
                    passwordVisibilityNotifier: _newVisibility,
                    validator: (value) =>
                        AuthValidationUtils.password(value, context),
                  ),
                  PasswordTextField(
                    controller: _confirmController,
                    label: context.l10n.confirmPassword,
                    passwordVisibilityNotifier: _confirmVisibility,
                    validator: (value) => AuthValidationUtils.confirmPassword(
                      value,
                      context,
                      _newController.text,
                    ),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwSections),
                  PrimaryButton(
                    text: context.l10n.changePassword,
                    rounded: true,
                    onPressed: _submitting ? null : _onSubmit,
                    isLoading: _submitting,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final error = await context
        .read<AuthCubit>()
        .reauthenticateAndChangePassword(
          _currentController.text,
          _newController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.passwordChangedSuccessfully)),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
