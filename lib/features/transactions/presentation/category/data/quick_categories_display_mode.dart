import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/l10.dart';

enum QuickCategoriesDisplayMode {
  recent,
  pinned;

  String label(BuildContext context) {
    return switch (this) {
      QuickCategoriesDisplayMode.recent => context.l10n.recent,
      QuickCategoriesDisplayMode.pinned => context.l10n.pinned,
    };
  }

  String description(BuildContext context) {
    return switch (this) {
      QuickCategoriesDisplayMode.recent =>
        context.l10n.showCategoriesFromYourLastTransactions,
      QuickCategoriesDisplayMode.pinned =>
        context.l10n.showCategoriesFromYourQuickCategories,
    };
  }

  static QuickCategoriesDisplayMode fromString(String value) {
    return QuickCategoriesDisplayMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuickCategoriesDisplayMode.recent,
    );
  }
}
