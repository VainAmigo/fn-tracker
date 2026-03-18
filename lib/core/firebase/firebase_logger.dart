import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Централизованное логирование запросов и ответов Firebase.
/// Работает только в debug-режиме.
abstract final class FirebaseLogger {
  static const _tag = 'Firebase';

  static bool get _enabled => kDebugMode;

  /// Логирует исходящий запрос.
  static void logRequest(
    String operation,
    Map<String, dynamic> request, {
    String? path,
  }) {
    if (!_enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('📤 ---- REQUEST: $operation');
    if (path != null) buffer.writeln('   path: $path');
    for (final e in request.entries) {
      buffer.writeln('   ${e.key}: ${e.value}');
    }
    developer.log(buffer.toString(), name: _tag);
  }

  /// Логирует успешный ответ.
  static void logResponse(
    String operation,
    Map<String, dynamic> response, {
    Duration? duration,
  }) {
    if (!_enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('📥 ---- RESPONSE: $operation');
    if (duration != null) {
      buffer.writeln('   duration: ${duration.inMilliseconds}ms');
    }
    for (final e in response.entries) {
      buffer.writeln('   ${e.key}: ${e.value}');
    }
    developer.log(buffer.toString(), name: _tag);
  }

  /// Логирует ошибку.
  static void logError(String operation, Object error, [StackTrace? stackTrace]) {
    if (!_enabled) return;
    developer.log(
      '❌ ERROR: $operation\n   $error',
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Оборачивает асинхронный вызов с логированием.
  static Future<T> withLogging<T>(
    String operation,
    Map<String, dynamic> request,
    Future<T> Function() fn, {
    Map<String, dynamic> Function(T result)? serializeResponse,
  }) async {
    logRequest(operation, request);
    final stopwatch = Stopwatch()..start();
    try {
      final result = await fn();
      stopwatch.stop();
      final response = serializeResponse?.call(result) ?? {'ok': true};
      response['duration_ms'] = stopwatch.elapsedMilliseconds;
      logResponse(operation, response, duration: stopwatch.elapsed);
      return result;
    } catch (e, st) {
      stopwatch.stop();
      logError(operation, e, st);
      rethrow;
    }
  }
}
