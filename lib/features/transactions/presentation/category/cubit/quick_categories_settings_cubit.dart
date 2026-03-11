import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/transactions/presentation/category/data/quick_categories_display_mode.dart';
import 'package:fn_tracker/features/transactions/presentation/category/cubit/quick_categories_settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyDisplayMode = 'quick_categories_display_mode';
const _keyPinnedOrder = 'quick_categories_pinned_order';

class QuickCategoriesSettingsCubit
    extends Cubit<QuickCategoriesSettingsState> {
  QuickCategoriesSettingsCubit()
      : super(QuickCategoriesSettingsState(
          displayMode: QuickCategoriesDisplayMode.recent,
        )) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStored = prefs.getString(_keyDisplayMode);
    final orderStored = prefs.getString(_keyPinnedOrder);

    final displayMode = modeStored != null
        ? QuickCategoriesDisplayMode.fromString(modeStored)
        : QuickCategoriesDisplayMode.recent;

    List<String> pinnedOrder = const [];
    if (orderStored != null) {
      try {
        final decoded = jsonDecode(orderStored) as List<dynamic>;
        pinnedOrder = decoded.cast<String>();
      } catch (_) {}
    }

    emit(QuickCategoriesSettingsState(
      displayMode: displayMode,
      pinnedOrder: pinnedOrder,
    ));
  }

  Future<void> setDisplayMode(QuickCategoriesDisplayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayMode, mode.name);
    emit(QuickCategoriesSettingsState(
      displayMode: mode,
      pinnedOrder: state.pinnedOrder,
    ));
  }

  Future<void> setPinnedOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPinnedOrder, jsonEncode(order));
    emit(QuickCategoriesSettingsState(
      displayMode: state.displayMode,
      pinnedOrder: order,
    ));
  }
}
