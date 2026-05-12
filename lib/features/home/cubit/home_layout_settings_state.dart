import 'package:fn_tracker/features/home/data/home_section.dart';

class HomeLayoutSettingsState {
  const HomeLayoutSettingsState({
    required this.sectionOrder,
    required this.sectionVisible,
  });

  /// Индексы [HomeSection.values] в порядке отображения.
  final List<int> sectionOrder;

  /// Видимость по ключу [HomeSection.storageKey].
  final Map<String, bool> sectionVisible;

  /// wallets → quickCategories → lastTransactions → budget
  static List<int> get defaultOrder => [
    HomeSection.wallets.index,
    HomeSection.quickCategories.index,
    HomeSection.lastTransactions.index,
    HomeSection.budget.index,
  ];

  static Map<String, bool> get defaultVisibility => {
    for (final s in HomeSection.values) s.storageKey: true,
  };

  factory HomeLayoutSettingsState.initial() => HomeLayoutSettingsState(
    sectionOrder: List<int>.from(defaultOrder),
    sectionVisible: Map<String, bool>.from(defaultVisibility),
  );

  bool isSectionVisible(HomeSection section) =>
      sectionVisible[section.storageKey] ?? true;

  HomeLayoutSettingsState copyWith({
    List<int>? sectionOrder,
    Map<String, bool>? sectionVisible,
  }) {
    return HomeLayoutSettingsState(
      sectionOrder: sectionOrder ?? this.sectionOrder,
      sectionVisible: sectionVisible ?? this.sectionVisible,
    );
  }
}
