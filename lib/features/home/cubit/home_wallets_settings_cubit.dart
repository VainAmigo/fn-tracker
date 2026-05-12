import 'package:fn_tracker/features/home/cubit/home_wallets_settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomeWalletsSettingsCubit extends HydratedCubit<HomeWalletsSettingsState> {
  HomeWalletsSettingsCubit() : super(const HomeWalletsSettingsState());

  @override
  String get storagePrefix => 'HomeWalletsSettingsCubit';

  @override
  HomeWalletsSettingsState? fromJson(Map<String, dynamic> json) {
    final raw = json['hiddenFromHomeIds'] as List<dynamic>?;
    final ids = raw?.map((e) => e as String).toSet() ?? const <String>{};
    final showHidden = json['showHiddenWalletsPlaceholderOnHome'] as bool? ??
        true;
    return HomeWalletsSettingsState(
      hiddenFromHomeIds: ids,
      showHiddenWalletsPlaceholderOnHome: showHidden,
    );
  }

  @override
  Map<String, dynamic>? toJson(HomeWalletsSettingsState state) {
    return {
      'hiddenFromHomeIds': state.hiddenFromHomeIds.toList(),
      'showHiddenWalletsPlaceholderOnHome':
          state.showHiddenWalletsPlaceholderOnHome,
    };
  }

  void clearForLogout() => emit(const HomeWalletsSettingsState());

  void setShowHiddenWalletsPlaceholderOnHome(bool show) {
    emit(state.copyWith(showHiddenWalletsPlaceholderOnHome: show));
  }

  void setWalletVisibleOnHome(String walletId, bool visible) {
    final next = Set<String>.from(state.hiddenFromHomeIds);
    if (visible) {
      next.remove(walletId);
    } else {
      next.add(walletId);
    }
    emit(state.copyWith(hiddenFromHomeIds: next));
  }
}
