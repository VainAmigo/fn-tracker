import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';

/// Сервис для хранения и проверки PIN-кода скрытых кошельков в Firebase.
class HiddenWalletsService {
  static const _pinField = 'pin';
  static const _path = 'users/{uid}/settings/hidden_wallets_pin';

  HiddenWalletsService._();
  static final HiddenWalletsService _instance = HiddenWalletsService._();
  static HiddenWalletsService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _pinDoc() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('hidden_wallets_pin');
  }

  /// Проверяет, задан ли PIN.
  Future<bool> get hasPin async {
    return FirebaseLogger.withLogging<bool>(
      'Firestore.hasPin',
      {'path': _path},
      () async {
        final doc = await _pinDoc().get();
        return doc.exists && doc.data()?[_pinField] != null;
      },
      serializeResponse: (v) => {'exists': v},
    ).catchError((_) => false);
  }

  /// Устанавливает PIN (при первом скрытии кошелька).
  Future<void> setPin(String pin) async {
    return FirebaseLogger.withLogging<void>(
      'Firestore.setPin',
      {'path': _path},
      () async {
        final encoded = base64Encode(utf8.encode(pin));
        await _pinDoc().set({_pinField: encoded});
      },
      serializeResponse: (_) => {'ok': true},
    );
  }

  /// Проверяет введённый PIN.
  Future<bool> verifyPin(String pin) async {
    return FirebaseLogger.withLogging<bool>(
      'Firestore.verifyPin',
      {'path': _path},
      () async {
        final doc = await _pinDoc().get();
        final stored = doc.data()?[_pinField] as String?;
        if (stored == null) return false;
        final decoded = utf8.decode(base64Decode(stored));
        return decoded == pin;
      },
      serializeResponse: (v) => {'valid': v},
    ).catchError((_) => false);
  }

  /// Меняет PIN (требуется текущий PIN для проверки).
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    return FirebaseLogger.withLogging<bool>(
      'Firestore.changePin',
      {'path': _path},
      () async {
        final valid = await verifyPin(currentPin);
        if (!valid) return false;
        await setPin(newPin);
        return true;
      },
      serializeResponse: (v) => {'ok': v},
    );
  }

  /// Удаляет сохранённый PIN (если все кошельки стали видимыми).
  Future<void> clearPin() async {
    return FirebaseLogger.withLogging<void>(
      'Firestore.clearPin',
      {'path': _path},
      () => _pinDoc().delete(),
      serializeResponse: (_) => {'ok': true},
    );
  }
}
