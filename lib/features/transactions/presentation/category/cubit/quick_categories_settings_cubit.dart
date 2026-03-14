import 'package:fn_tracker/features/transactions/presentation/category/data/quick_categories_display_mode.dart';
import 'package:fn_tracker/features/transactions/presentation/category/cubit/quick_categories_settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class QuickCategoriesSettingsCubit
    extends HydratedCubit<QuickCategoriesSettingsState> {
  QuickCategoriesSettingsCubit()
      : super(const QuickCategoriesSettingsState(
          displayMode: QuickCategoriesDisplayMode.recent,
        ));

  @override
  String get storagePrefix => 'QuickCategoriesSettingsCubit';

  @override
  QuickCategoriesSettingsState? fromJson(Map<String, dynamic> json) {
    final displayMode = QuickCategoriesDisplayMode.fromString(
      json['displayMode'] as String? ?? 'recent',
    );
    final pinnedOrder = (json['pinnedOrder'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [];
    return QuickCategoriesSettingsState(
      displayMode: displayMode,
      pinnedOrder: pinnedOrder,
    );
  }

  @override
  Map<String, dynamic>? toJson(QuickCategoriesSettingsState state) {
    return {
      'displayMode': state.displayMode.name,
      'pinnedOrder': state.pinnedOrder,
    };
  }

  void clearForLogout() => emit(const QuickCategoriesSettingsState(
        displayMode: QuickCategoriesDisplayMode.recent,
      ));

  Future<void> setDisplayMode(QuickCategoriesDisplayMode mode) async {
    emit(QuickCategoriesSettingsState(
      displayMode: mode,
      pinnedOrder: state.pinnedOrder,
    ));
  }

  Future<void> setPinnedOrder(List<String> order) async {
    emit(QuickCategoriesSettingsState(
      displayMode: state.displayMode,
      pinnedOrder: order,
    ));
  }
}
