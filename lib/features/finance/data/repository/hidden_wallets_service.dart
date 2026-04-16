import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/core/core.dart';

/// Сервис для хранения и проверки PIN-кода скрытых кошельков в Firebase.
class HiddenWalletsService {
  static const _pinField = 'pin';
  static const _docId = 'hidden_wallets_pin';

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
        .doc(_docId);
  }

  String get _resolvedCollection {
    final uid = _auth.currentUser?.uid ?? '?';
    return 'users/$uid/settings';
  }

  /// Проверяет, задан ли PIN.
  Future<bool> get hasPin async {
    return FirebaseLogger.query<bool>(
      operation: 'hasPin',
      collection: _resolvedCollection,
      filters: {'docId': _docId},
      fn: () async {
        final doc = await _pinDoc().get();
        return doc.exists && doc.data()?[_pinField] != null;
      },
      serialize: (v) => {'exists': v},
    ).catchError((_) => false);
  }

  /// Устанавливает PIN (при первом скрытии кошелька).
  Future<void> setPin(String pin) async {
    return FirebaseLogger.mutation<void>(
      operation: 'setPin',
      collection: _resolvedCollection,
      docId: _docId,
      fn: () async {
        final encoded = base64Encode(utf8.encode(pin));
        await _pinDoc().set({_pinField: encoded});
      },
    );
  }

  /// Проверяет введённый PIN.
  Future<bool> verifyPin(String pin) async {
    return FirebaseLogger.query<bool>(
      operation: 'verifyPin',
      collection: _resolvedCollection,
      filters: {'docId': _docId},
      fn: () async {
        final doc = await _pinDoc().get();
        final stored = doc.data()?[_pinField] as String?;
        if (stored == null) return false;
        final decoded = utf8.decode(base64Decode(stored));
        return decoded == pin;
      },
      serialize: (v) => {'valid': v},
    ).catchError((_) => false);
  }

  /// Меняет PIN (требуется текущий PIN для проверки).
  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    return FirebaseLogger.mutation<bool>(
      operation: 'changePin',
      collection: _resolvedCollection,
      docId: _docId,
      fn: () async {
        final valid = await verifyPin(currentPin);
        if (!valid) return false;
        await setPin(newPin);
        return true;
      },
      serialize: (v) => {'success': v},
    );
  }

  /// Удаляет сохранённый PIN (если все кошельки стали видимыми).
  Future<void> clearPin() async {
    return FirebaseLogger.mutation<void>(
      operation: 'clearPin',
      collection: _resolvedCollection,
      docId: _docId,
      fn: () => _pinDoc().delete(),
    );
  }
}
