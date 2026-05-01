import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/finance/data/data.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

import 'app_lock_settings_controller.dart';
import 'biometric_auth_service.dart';
import 'sensitive_unlock_coordinator.dart';

/// После входа в аккаунт: опционально блокирует приложение до PIN/биометрии.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final _settings = AppLockSettingsController.instance;

  bool _loading = true;
  bool _hasPin = false;
  bool _needLock = false;
  bool _unlocked = false;
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings.addListener(_onSettingsChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSettingsChanged() {
    scheduleMicrotask(_syncLockRequirement);
  }

  Future<void> _bootstrap() async {
    await _settings.load();
    await _syncLockRequirement();
  }

  Future<void> _syncLockRequirement() async {
    final hasPin = await HiddenWalletsService.instance.hasPin;
    if (!mounted) return;

    final needLock = _settings.appLockEnabled && hasPin;
    final wasNeed = _needLock;

    setState(() {
      _loading = false;
      _hasPin = hasPin;
      _needLock = needLock;
      if (!needLock) {
        _unlocked = true;
      } else if (!wasNeed && needLock) {
        _unlocked = false;
      }
    });

    if (needLock && !_unlocked && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_tryLaunchBiometric());
      });
    }
  }

  Future<void> _tryLaunchBiometric() async {
    if (!_needLock || _unlocked || !mounted) return;
    if (!_settings.biometricUnlockEnabled) return;

    final bio = BiometricAuthService();
    if (!await bio.hasEnrolledBiometrics()) return;
    if (!mounted) return;
    final reason = context.l10n.biometricPromptUnlock;

    final ok = await bio.authenticate(localizedReason: reason);
    if (ok && mounted) setState(() => _unlocked = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      if (_needLock && _hasPin) {
        setState(() => _unlocked = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_tryLaunchBiometric());
        });
      }
    }
  }

  Future<void> _onUseBiometricPressed() => _tryLaunchBiometric();

  Future<void> _onUnlockWithPinPressed() async {
    final result = await SensitiveUnlockCoordinator.verifyForAppUnlock(context);
    if (result == true && mounted) setState(() => _unlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_needLock || _unlocked) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final showBio = _settings.biometricUnlockEnabled;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizing.spaceBtwSections),
              Icon(Icons.lock_outline, size: 56, color: colorScheme.primary),
              const SizedBox(height: AppSizing.spaceBtwElements),
              Text(
                context.l10n.unlockAppTitle,
                style: AppTextStyles.text20w600(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizing.spaceBtwItems),
              Text(
                context.l10n.unlockAppSubtitle,
                style: AppTextStyles.text16w400(context),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (showBio) ...[
                PrimaryButton(
                  text: context.l10n.useBiometricButton,
                  icon: Icons.fingerprint,
                  onPressed: _onUseBiometricPressed,
                  size: PrimaryButtonSize.medium,
                ),
                const SizedBox(height: AppSizing.spaceBtwItems),
              ],
              PrimaryButton(
                text: context.l10n.enterPin,
                icon: Icons.pin_outlined,
                onPressed: _onUnlockWithPinPressed,
                size: PrimaryButtonSize.medium,
                backgroundColor: showBio
                    ? colorScheme.secondary
                    : null,
                foregroundColor: showBio
                    ? colorScheme.onSecondary
                    : null,
              ),
              const SizedBox(height: AppSizing.bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}
