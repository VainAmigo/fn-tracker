import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fn_tracker/core/app_groups/category_color_palettes.dart';
import 'package:fn_tracker/features/features.dart';

class AndroidWidgetCategoryPayload {
  const AndroidWidgetCategoryPayload({
    required this.id,
    required this.name,
    required this.color,
    required this.iconId,
  });

  final String id;
  final String name;
  final int color;
  final String iconId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'icon_id': iconId,
  };
}

class AndroidWidgetBridge {
  AndroidWidgetBridge._();

  static const MethodChannel _methodChannel = MethodChannel(
    'fn_tracker/android_widget/methods',
  );
  static const EventChannel _eventChannel = EventChannel(
    'fn_tracker/android_widget/events',
  );

  static StreamSubscription<dynamic>? _subscription;
  static bool _initialized = false;

  static Future<void> init({
    required Future<void> Function(String categoryId) onCategoryTap,
  }) async {
    if (_initialized) return;
    _initialized = true;

    final initialCategoryId = await _methodChannel.invokeMethod<String>(
      'consumeInitialCategoryId',
    );
    if (initialCategoryId != null && initialCategoryId.isNotEmpty) {
      await onCategoryTap(initialCategoryId);
    }

    _subscription = _eventChannel
        .receiveBroadcastStream()
        .listen((dynamic value) async {
          final id = value?.toString();
          if (id == null || id.isEmpty) return;
          await onCategoryTap(id);
        });
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  static Future<void> syncCategories({
    required List<CategoryModel> categories,
    required List<String> pinnedIds,
    required List<String> recentIds,
  }) async {
    final payload = categories
        .map(
          (category) => AndroidWidgetCategoryPayload(
            id: category.categoryId,
            name: category.name,
            color: findShadeById(category.colorId)?.color.toARGB32() ?? 0xFF9E9E9E,
            iconId: category.iconId,
          ).toJson(),
        )
        .toList();

    await _methodChannel.invokeMethod<void>('syncWidgetData', {
      'categories_json': jsonEncode(payload),
      'pinned_ids_json': jsonEncode(pinnedIds),
      'recent_ids_json': jsonEncode(recentIds),
      'updated_at_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> clear() async {
    await _methodChannel.invokeMethod<void>('clearWidgetData');
  }
}
