import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/l10.dart';

enum WidgetCategoriesSource {
  system,
  custom;

  String label(BuildContext context) {
    return switch (this) {
      WidgetCategoriesSource.system => context.l10n.systemQuickCategories,
      WidgetCategoriesSource.custom => context.l10n.customCategories,
    };
  }

  String description(BuildContext context) {
    return switch (this) {
      WidgetCategoriesSource.system =>
        context.l10n.userQuickCategories,
      WidgetCategoriesSource.custom =>
        context.l10n.chooseFixedCategories,
    };
  }

  static WidgetCategoriesSource fromString(String value) {
    return WidgetCategoriesSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WidgetCategoriesSource.system,
    );
  }
}
