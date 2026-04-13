import 'package:shared_preferences/shared_preferences.dart';

/// Локальное сохранение порядка иконок табов аналитики (не сервер).
abstract final class AnalyticsTabOrderStorage {
  static const _key = 'analytics_tab_bar_order_v1';

  /// Логические индексы: 0 donut, 1 bar, 2 heatmap, 3 AI.
  static const List<int> defaultOrder = [0, 1, 2, 3];

  static Future<List<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return List<int>.from(defaultOrder);
    }
    final parts = raw.split(',');
    if (parts.length != defaultOrder.length) {
      return List<int>.from(defaultOrder);
    }
    try {
      final parsed = parts.map(int.parse).toList();
      if (!_isValidPermutation(parsed)) {
        return List<int>.from(defaultOrder);
      }
      return parsed;
    } on FormatException {
      return List<int>.from(defaultOrder);
    }
  }

  static Future<void> save(List<int> order) async {
    if (!_isValidPermutation(order)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, order.join(','));
  }

  static bool _isValidPermutation(List<int> order) {
    if (order.length != defaultOrder.length) return false;
    final set = order.toSet();
    if (set.length != defaultOrder.length) return false;
    for (final i in order) {
      if (i < 0 || i >= defaultOrder.length) return false;
    }
    return true;
  }
}
