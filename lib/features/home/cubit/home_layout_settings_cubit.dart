import 'package:fn_tracker/features/home/cubit/home_layout_settings_state.dart';
import 'package:fn_tracker/features/home/data/home_section.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomeLayoutSettingsCubit extends HydratedCubit<HomeLayoutSettingsState> {
  HomeLayoutSettingsCubit() : super(HomeLayoutSettingsState.initial());

  @override
  String get storagePrefix => 'HomeLayoutSettingsCubit';

  static const _orderKey = 'sectionOrder';
  static const _visibleKey = 'sectionVisible';

  @override
  HomeLayoutSettingsState? fromJson(Map<String, dynamic> json) {
    final n = HomeSection.values.length;
    final rawOrder = json[_orderKey] as List<dynamic>?;
    List<int> order;
    if (rawOrder == null ||
        rawOrder.length != n ||
        !_isValidPermutation(
          rawOrder.map((e) => e as int).toList(),
          n,
        )) {
      order = List<int>.from(HomeLayoutSettingsState.defaultOrder);
    } else {
      order = rawOrder.map((e) => e as int).toList();
    }

    final rawVis = json[_visibleKey] as Map<String, dynamic>?;
    final vis = Map<String, bool>.from(HomeLayoutSettingsState.defaultVisibility);
    if (rawVis != null) {
      for (final s in HomeSection.values) {
        final v = rawVis[s.storageKey];
        if (v is bool) {
          vis[s.storageKey] = v;
        }
      }
    }

    return HomeLayoutSettingsState(sectionOrder: order, sectionVisible: vis);
  }

  @override
  Map<String, dynamic>? toJson(HomeLayoutSettingsState state) {
    return {
      _orderKey: state.sectionOrder,
      _visibleKey: state.sectionVisible,
    };
  }

  void clearForLogout() => emit(HomeLayoutSettingsState.initial());

  void setSectionVisible(HomeSection section, bool visible) {
    final next = Map<String, bool>.from(state.sectionVisible);
    next[section.storageKey] = visible;
    emit(state.copyWith(sectionVisible: next));
  }

  void reorderSections(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final next = List<int>.from(state.sectionOrder);
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    emit(state.copyWith(sectionOrder: next));
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
