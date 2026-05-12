import 'finance_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальное сохранение порядка табов экрана «Финансы».
abstract final class FinanceTabOrderStorage {
  static const _key = 'finance_tab_bar_order_v1';

  /// Индексы [FinanceTab.values].
  static List<int> get defaultOrder =>
      List<int>.generate(FinanceTab.values.length, (i) => i);

  static Future<List<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final n = FinanceTab.values.length;
    if (raw == null || raw.isEmpty) {
      return List<int>.from(defaultOrder);
    }
    final parts = raw.split(',');
    if (parts.length != n) {
      return List<int>.from(defaultOrder);
    }
    try {
      final parsed = parts.map(int.parse).toList();
      if (!_isValidPermutation(parsed, n)) {
        return List<int>.from(defaultOrder);
      }
      return parsed;
    } on FormatException {
      return List<int>.from(defaultOrder);
    }
  }

  static Future<void> save(List<int> order) async {
    final n = FinanceTab.values.length;
    if (!_isValidPermutation(order, n)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, order.join(','));
  }

  static bool _isValidPermutation(List<int> order, int n) {
    if (order.length != n) return false;
    final set = order.toSet();
    if (set.length != n) return false;
    for (final i in order) {
      if (i < 0 || i >= n) return false;
    }
    return true;
  }
}
