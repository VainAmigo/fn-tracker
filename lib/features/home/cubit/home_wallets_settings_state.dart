class HomeWalletsSettingsState {
  const HomeWalletsSettingsState({
    this.hiddenFromHomeIds = const {},
  });

  /// ID кошельков, скрытых только на главном экране (не влияет на вкладку «Счета»).
  final Set<String> hiddenFromHomeIds;

  HomeWalletsSettingsState copyWith({
    Set<String>? hiddenFromHomeIds,
  }) {
    return HomeWalletsSettingsState(
      hiddenFromHomeIds: hiddenFromHomeIds ?? this.hiddenFromHomeIds,
    );
  }
}
