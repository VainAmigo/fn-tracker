import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/finance/data/data.dart';
import 'package:fn_tracker/l10n/l10.dart';

import 'app_lock_settings_controller.dart';
import 'biometric_auth_service.dart';

/// Общая проверка: биометрия (если включена) → ввод PIN через тот же sheet, что и скрытые карты.
class SensitiveUnlockCoordinator {
  const SensitiveUnlockCoordinator._();

  /// Для скрытых кошельков/целей и любых действий с тем же PIN.
  static Future<bool?> verifyForSensitiveAction(BuildContext context) async {
    final hasPin = await HiddenWalletsService.instance.hasPin;
    if (!hasPin) return true;

    final settings = AppLockSettingsController.instance;
    if (!settings.isLoaded) await settings.load();

    if (settings.biometricUnlockEnabled && context.mounted) {
      final bio = BiometricAuthService();
      if (await bio.hasEnrolledBiometrics()) {
        if (!context.mounted) return false;
        final reason = context.l10n.biometricPromptUnlock;
        final ok = await bio.authenticate(localizedReason: reason);
        if (ok) return true;
      }
    }

    if (!context.mounted) return false;

    return PasswordFormModalSheet.show(
      context,
      title: context.l10n.hiddenCards,
      subtitle: context.l10n.enterPinToView,
      submitLabel: context.l10n.open,
      onSubmit: (pin) async {
        final valid = await HiddenWalletsService.instance.verifyPin(pin);
        if (!valid && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.invalidPin)),
          );
        }
        return valid;
      },
    );
  }

  /// Только биометрия + PIN-лист (без заголовка «скрытые карты») — для полноэкранной блокировки приложения.
  static Future<bool?> verifyForAppUnlock(BuildContext context) async {
    final hasPin = await HiddenWalletsService.instance.hasPin;
    if (!hasPin) return true;

    final settings = AppLockSettingsController.instance;
    if (!settings.isLoaded) await settings.load();

    if (settings.biometricUnlockEnabled && context.mounted) {
      final bio = BiometricAuthService();
      if (await bio.hasEnrolledBiometrics()) {
        if (!context.mounted) return false;
        final reason = context.l10n.biometricPromptUnlock;
        final ok = await bio.authenticate(localizedReason: reason);
        if (ok) return true;
      }
    }

    if (!context.mounted) return false;

    return PasswordFormModalSheet.show(
      context,
      title: context.l10n.unlockAppTitle,
      subtitle: context.l10n.unlockAppSubtitle,
      submitLabel: context.l10n.open,
      onSubmit: (pin) async {
        final valid = await HiddenWalletsService.instance.verifyPin(pin);
        if (!valid && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.invalidPin)),
          );
        }
        return valid;
      },
    );
  }
}
