import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Результат проверки биометрии в настройках ОС (не путать с сбоем плагина).
enum BiometricEnrollmentStatus {
  /// Есть хотя бы один отпечаток / Face ID и т.д.
  enrolled,

  /// Устройство поддерживает биометрию, но пользователь ничего не добавил в системных настройках.
  noneEnrolled,

  /// ОС сообщает, что локальной биометрии нет (редко на телефонах; часто эмулятор).
  unsupported,

  /// Ошибка канала local_auth — статус неизвестен (пересборка, эмулятор, ранний вызов).
  probeFailed,
}

/// Обёртка над [LocalAuthentication] для единого вызова из экрана блокировки и скрытых карт.
class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Точная проверка: почему биометрия недоступна для переключателя в настройках.
  Future<BiometricEnrollmentStatus> getEnrollmentStatus() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return BiometricEnrollmentStatus.unsupported;
      final types = await _auth.getAvailableBiometrics();
      if (types.isEmpty) return BiometricEnrollmentStatus.noneEnrolled;
      return BiometricEnrollmentStatus.enrolled;
    } on PlatformException {
      return BiometricEnrollmentStatus.probeFailed;
    } on Object {
      return BiometricEnrollmentStatus.probeFailed;
    }
  }

  /// Есть ли что-то для биометрии (отпечаток, Face ID и т.д.).
  Future<bool> hasEnrolledBiometrics() async {
    final s = await getEnrollmentStatus();
    return s == BiometricEnrollmentStatus.enrolled;
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        sensitiveTransaction: true,
      );
    } on PlatformException {
      return false;
    } on Object {
      return false;
    }
  }
}
