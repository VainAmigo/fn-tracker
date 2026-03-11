enum QuickCategoriesDisplayMode {
  recent,
  pinned;

  String get label {
    return switch (this) {
      QuickCategoriesDisplayMode.recent => 'Recent',
      QuickCategoriesDisplayMode.pinned => 'Pinned',
    };
  }

  String get description {
    return switch (this) {
      QuickCategoriesDisplayMode.recent =>
        'Show categories from your last transactions',
      QuickCategoriesDisplayMode.pinned =>
        'Show categories you\'ve pinned for quick access',
    };
  }

  static QuickCategoriesDisplayMode fromString(String value) {
    return QuickCategoriesDisplayMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuickCategoriesDisplayMode.recent,
    );
  }
}
