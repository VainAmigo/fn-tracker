import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/finance/data/data.dart';
import 'package:fn_tracker/features/settings/security/app_lock_settings_controller.dart';
import 'package:fn_tracker/features/settings/security/biometric_auth_service.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  final _settings = AppLockSettingsController.instance;

  bool _ready = false;
  bool _hasPin = false;
  BiometricEnrollmentStatus _biometricStatus =
      BiometricEnrollmentStatus.probeFailed;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsListenable);
    // local_auth на Android связывается с Activity после первого кадра; иначе возможен channel-error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshLocalState();
    });
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsListenable);
    super.dispose();
  }

  void _onSettingsListenable() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshLocalState() async {
    await _settings.load();
    final hasPin = await HiddenWalletsService.instance.hasPin;
    final bioStatus = await BiometricAuthService().getEnrollmentStatus();
    if (!mounted) return;
    setState(() {
      _ready = true;
      _hasPin = hasPin;
      _biometricStatus = bioStatus;
    });
  }

  Future<void> _onSetOrChangePin() async {
    if (_hasPin) {
      final result = await ChangePinFormModalSheet.show(
        context,
        title: context.l10n.changePin,
        onSubmit: (currentPin, newPin) async {
          return HiddenWalletsService.instance.changePin(
            currentPin: currentPin,
            newPin: newPin,
          );
        },
      );
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.pinSuccessfullyChanged)),
        );
      }
    } else {
      final result = await PasswordFormModalSheet.show(
        context,
        title: context.l10n.setPin,
        subtitle: context.l10n.pinRequiredForHiddenCards,
        isSetMode: true,
        submitLabel: context.l10n.setPin,
        confirmLabel: context.l10n.setPin,
        onSubmit: (pin) async {
          await HiddenWalletsService.instance.setPin(pin);
          return true;
        },
      );
      if (result == true && mounted) {
        await _refreshLocalState();
      }
    }
  }

  Future<void> _onAppLockChanged(bool value) async {
    if (value) {
      if (!_hasPin && mounted) {
        final ok = await PasswordFormModalSheet.show(
          context,
          title: context.l10n.setPin,
          subtitle: context.l10n.pinRequiredForHiddenCards,
          isSetMode: true,
          submitLabel: context.l10n.setPin,
          confirmLabel: context.l10n.setPin,
          onSubmit: (pin) async {
            await HiddenWalletsService.instance.setPin(pin);
            return true;
          },
        );
        if (ok != true) return;
        await _refreshLocalState();
      }
      await _settings.setAppLockEnabled(true);
    } else {
      await _settings.setAppLockEnabled(false);
    }
  }

  Future<void> _onBiometricChanged(bool value) async {
    if (value) {
      if (_biometricStatus != BiometricEnrollmentStatus.enrolled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_biometricHintText(context))),
          );
        }
        return;
      }
      if (!_hasPin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.pinRequiredForHiddenCards)),
          );
        }
        return;
      }
    }
    await _settings.setBiometricUnlockEnabled(value);
  }

  String _biometricHintText(BuildContext context) {
    return switch (_biometricStatus) {
      BiometricEnrollmentStatus.noneEnrolled =>
        context.l10n.biometricsHintNoneEnrolled,
      BiometricEnrollmentStatus.unsupported =>
        context.l10n.biometricsHintUnsupported,
      BiometricEnrollmentStatus.probeFailed =>
        context.l10n.biometricsHintProbeFailed,
      BiometricEnrollmentStatus.enrolled => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.security),
          scrolledUnderElevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final s = _settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.security),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabTitleWidget(
                  title: context.l10n.security,
                  subtitle: context.l10n.securityIntro,
                ),
                const SizedBox(height: AppSizing.spaceBtwSections),
                TitledSection(
                  title: context.l10n.pinSectionTitle,
                  children: [
                    CategoryCard(
                      title: _hasPin ? context.l10n.changePin : context.l10n.setPin,
                      subtitle: _hasPin
                          ? context.l10n.pinSetSubtitle
                          : context.l10n.pinNotSetSubtitle,
                      radius: CardRadius.first,
                      leading: const Icon(Icons.pin_outlined),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _onSetOrChangePin,
                    ),
                    const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                    _SecurityToggleTile(
                      title: context.l10n.appLockTitle,
                      subtitle: context.l10n.appLockSubtitle,
                      value: s.appLockEnabled,
                      onChanged: _onAppLockChanged,
                      radius: CardRadius.middle,
                    ),
                    const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                    _SecurityToggleTile(
                      title: context.l10n.biometricUnlockTitle,
                      subtitle: context.l10n.biometricUnlockSubtitle,
                      value: s.biometricUnlockEnabled,
                      onChanged: _onBiometricChanged,
                      radius: CardRadius.last,
                    ),
                  ],
                ),
                if (_biometricStatus != BiometricEnrollmentStatus.enrolled) ...[
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  Text(
                    _biometricHintText(context),
                    style: AppTextStyles.text14w400(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityToggleTile extends StatelessWidget {
  const _SecurityToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.radius,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final CardRadius radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final br = borderRadiusFor(radius);
    return Material(
      color: colorScheme.secondary,
      borderRadius: br,
      child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.spaceBtwElements,
            vertical: AppSizing.spaceBtwItemsExtra,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: AppTextStyles.text14w400(
                        context,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                    Text(title, style: AppTextStyles.listTileTitle(context)),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
    );
  }
}
