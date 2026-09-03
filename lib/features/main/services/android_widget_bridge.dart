import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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

    try {
      final initialCategoryId = await _methodChannel.invokeMethod<String>(
        'consumeInitialCategoryId',
      );
      if (initialCategoryId != null && initialCategoryId.isNotEmpty) {
        await onCategoryTap(initialCategoryId);
      }
    } on MissingPluginException {
      return;
    }

    _subscription = _eventChannel.receiveBroadcastStream().listen((
      dynamic value,
    ) async {
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
    required ColorScheme colorScheme,
    required String emptyLabel,
  }) async {
    final payload = categories
        .map(
          (category) => AndroidWidgetCategoryPayload(
            id: category.categoryId,
            name: category.name,
            color:
                findShadeById(category.colorId)?.color.toARGB32() ?? 0xFF9E9E9E,
            iconId: category.iconId,
          ).toJson(),
        )
        .toList();

    try {
      await _methodChannel.invokeMethod<void>('syncWidgetData', {
        'categories_json': jsonEncode(payload),
        'empty_label': emptyLabel,
        'theme_surface': colorScheme.surface.toARGB32(),
        'theme_secondary': colorScheme.secondary.toARGB32(),
        'theme_on_surface': colorScheme.onSurface.toARGB32(),
        'theme_on_secondary': colorScheme.onSecondary.toARGB32(),
        'theme_primary': colorScheme.primary.toARGB32(),
        'updated_at_ms': DateTime.now().millisecondsSinceEpoch,
      });
    } on MissingPluginException {
      return;
    }
  }

  static Future<void> clear({
    ColorScheme? colorScheme,
    String emptyLabel = '',
  }) async {
    try {
      await _methodChannel.invokeMethod<void>('clearWidgetData', {
        'empty_label': emptyLabel,
        if (colorScheme != null) ...{
          'theme_surface': colorScheme.surface.toARGB32(),
          'theme_secondary': colorScheme.secondary.toARGB32(),
          'theme_on_surface': colorScheme.onSurface.toARGB32(),
          'theme_on_secondary': colorScheme.onSecondary.toARGB32(),
          'theme_primary': colorScheme.primary.toARGB32(),
        },
      });
    } on MissingPluginException {
      return;
    }
  }
}
