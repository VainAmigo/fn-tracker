import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Централизованное логирование запросов и ответов Firebase.
/// Работает только в debug-режиме.
abstract final class FirebaseLogger {
  static const _tag = 'Firebase';
  static const _maxItemsPreview = 5;
  static const _maxValueLength = 200;

  static bool get _enabled => kDebugMode;

  static String _formatMap(Map<String, dynamic> map, {String indent = '   '}) {
    final buffer = StringBuffer();
    for (final e in map.entries) {
      final value = _truncateValue(e.value);
      buffer.writeln('$indent${e.key}: $value');
    }
    return buffer.toString();
  }

  static String _truncateValue(dynamic value) {
    final str = '$value';
    if (str.length <= _maxValueLength) return str;
    return '${str.substring(0, _maxValueLength)}…';
  }

  static String _formatList(
    List<Map<String, dynamic>> items, {
    String indent = '   ',
  }) {
    if (items.isEmpty) return '$indent(empty)\n';
    final buffer = StringBuffer();
    final count = items.length;
    final preview = items.take(_maxItemsPreview);
    for (final (i, item) in preview.indexed) {
      buffer.writeln('$indent[$i] ${_truncateValue(item)}');
    }
    if (count > _maxItemsPreview) {
      buffer.writeln('$indent... и ещё ${count - _maxItemsPreview} записей');
    }
    return buffer.toString();
  }

  /// Логирует исходящий запрос с подробностями.
  static void logRequest(
    String operation, {
    String? collection,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? data,
    String? docId,
  }) {
    if (!_enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('┌─ 📤 $operation');
    if (collection != null) buffer.writeln('│  collection: $collection');
    if (docId != null) buffer.writeln('│  docId: $docId');
    if (filters != null && filters.isNotEmpty) {
      buffer.writeln('│  filters:');
      buffer.write(_formatMap(filters, indent: '│     '));
    }
    if (data != null && data.isNotEmpty) {
      buffer.writeln('│  data:');
      buffer.write(_formatMap(data, indent: '│     '));
    }
    buffer.write('│');
    developer.log(buffer.toString(), name: _tag);
  }

  /// Логирует успешный ответ с данными.
  static void logResponse(
    String operation, {
    required int durationMs,
    int? docsCount,
    List<Map<String, dynamic>>? docs,
    Map<String, dynamic>? data,
  }) {
    if (!_enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('│');
    buffer.writeln('│  ⏱ ${durationMs}ms');
    if (docsCount != null) buffer.writeln('│  docs: $docsCount');
    if (docs != null && docs.isNotEmpty) {
      buffer.write(_formatList(docs, indent: '│  '));
    }
    if (data != null && data.isNotEmpty) {
      buffer.writeln('│  result:');
      buffer.write(_formatMap(data, indent: '│     '));
    }
    buffer.writeln('└─ ✅ $operation');
    buffer.writeln('');
    developer.log(buffer.toString(), name: _tag);
  }

  /// Логирует ошибку.
  static void logError(
    String operation,
    Object error, {
    required int durationMs,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('│');
    buffer.writeln('│  ⏱ ${durationMs}ms');
    buffer.writeln('└─ ❌ $operation: $error');
    buffer.writeln('');
    developer.log(
      buffer.toString(),
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Оборачивает Firestore-запрос на чтение коллекции.
  static Future<T> query<T>({
    required String operation,
    required String collection,
    Map<String, dynamic>? filters,
    required Future<T> Function() fn,
    required Map<String, dynamic> Function(T result) serialize,
  }) async {
    logRequest(operation, collection: collection, filters: filters);
    final sw = Stopwatch()..start();
    try {
      final result = await fn();
      sw.stop();
      final serialized = serialize(result);
      final docsCount = serialized.remove('_docsCount') as int?;
      final docs =
          serialized.remove('_docs') as List<Map<String, dynamic>>?;
      logResponse(
        operation,
        durationMs: sw.elapsedMilliseconds,
        docsCount: docsCount,
        docs: docs,
        data: serialized.isNotEmpty ? serialized : null,
      );
      return result;
    } catch (e, st) {
      sw.stop();
      logError(operation, e, durationMs: sw.elapsedMilliseconds, stackTrace: st);
      rethrow;
    }
  }

  /// Оборачивает Firestore-запрос на запись / мутацию.
  static Future<T> mutation<T>({
    required String operation,
    required String collection,
    String? docId,
    Map<String, dynamic>? data,
    required Future<T> Function() fn,
    Map<String, dynamic> Function(T result)? serialize,
  }) async {
    logRequest(operation, collection: collection, docId: docId, data: data);
    final sw = Stopwatch()..start();
    try {
      final result = await fn();
      sw.stop();
      final serialized = serialize?.call(result);
      logResponse(
        operation,
        durationMs: sw.elapsedMilliseconds,
        data: serialized,
      );
      return result;
    } catch (e, st) {
      sw.stop();
      logError(operation, e, durationMs: sw.elapsedMilliseconds, stackTrace: st);
      rethrow;
    }
  }
}
