import 'package:flutter/widgets.dart';

import 'package:fn_tracker/l10n/l10.dart';

class AuthValidationUtils {
  AuthValidationUtils._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value, BuildContext context) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) {
      return l10n.enterYourEmail;
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return l10n.invalidEmail;
    }

    return null;
  }

  static String? password(
    String? value,
    BuildContext context, {
    int minLength = 6,
  }) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.enterYourPassword;
    }

    if (value.length < minLength) {
      return l10n.passwordMustBeAtLeast(minLength);
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    BuildContext context,
    String originalPassword, {
    int minLength = 6,
  }) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.confirmYourPassword;
    }

    if (value.length < minLength) {
      return l10n.passwordMustBeAtLeast(minLength);
    }

    if (value != originalPassword) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }
}
