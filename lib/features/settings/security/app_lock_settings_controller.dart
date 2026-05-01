import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальные флаги: блокировка приложения и приоритет биометрии.
/// PIN хранится в [HiddenWalletsService] (Firestore) — один на приложение и скрытые карты.
class AppLockSettingsController extends ChangeNotifier {
  AppLockSettingsController._();
  static final instance = AppLockSettingsController._();

  static const _kAppLock = 'app_lock_enabled';
  static const _kBiometric = 'biometric_unlock_enabled';

  bool appLockEnabled = false;
  bool biometricUnlockEnabled = false;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    appLockEnabled = p.getBool(_kAppLock) ?? false;
    biometricUnlockEnabled = p.getBool(_kBiometric) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAppLock, value);
    appLockEnabled = value;
    notifyListeners();
  }

  Future<void> setBiometricUnlockEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kBiometric, value);
    biometricUnlockEnabled = value;
    notifyListeners();
  }
}
