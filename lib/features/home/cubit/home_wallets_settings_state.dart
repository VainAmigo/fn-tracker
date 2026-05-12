class HomeWalletsSettingsState {
  const HomeWalletsSettingsState({
    this.hiddenFromHomeIds = const {},
    this.showHiddenWalletsPlaceholderOnHome = true,
  });

  /// ID кошельков, скрытых только на главном экране (не влияет на вкладку «Счета»).
  final Set<String> hiddenFromHomeIds;

  /// Плитка «Скрытые карточки» в горизонтальном списке на главной.
  final bool showHiddenWalletsPlaceholderOnHome;

  HomeWalletsSettingsState copyWith({
    Set<String>? hiddenFromHomeIds,
    bool? showHiddenWalletsPlaceholderOnHome,
  }) {
    return HomeWalletsSettingsState(
      hiddenFromHomeIds: hiddenFromHomeIds ?? this.hiddenFromHomeIds,
      showHiddenWalletsPlaceholderOnHome:
          showHiddenWalletsPlaceholderOnHome ??
          this.showHiddenWalletsPlaceholderOnHome,
    );
  }
}
