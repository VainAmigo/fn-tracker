enum WidgetCategoriesSource {
  system,
  custom;

  String get label {
    return switch (this) {
      WidgetCategoriesSource.system => 'System quick categories',
      WidgetCategoriesSource.custom => 'Custom widget categories',
    };
  }

  String get description {
    return switch (this) {
      WidgetCategoriesSource.system =>
        'Use categories from current quick mode (Recent or Pinned)',
      WidgetCategoriesSource.custom =>
        'Choose a fixed list of categories for the home screen widget',
    };
  }

  static WidgetCategoriesSource fromString(String value) {
    return WidgetCategoriesSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WidgetCategoriesSource.system,
    );
  }
}
