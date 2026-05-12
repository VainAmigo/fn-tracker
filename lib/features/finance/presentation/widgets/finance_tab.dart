import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Табы экрана «Финансы». Единый источник истины для переключателя и контента.
enum FinanceTab {
  budget,
  accounts,
  transactions,
  categories,
  scheduledPayments,
}

extension FinanceTabX on FinanceTab {
  String label(BuildContext context) {
    switch (this) {
      case FinanceTab.budget:
        return context.l10n.budget;
      case FinanceTab.accounts:
        return context.l10n.accounts;
      case FinanceTab.transactions:
        return context.l10n.transactions;
      case FinanceTab.categories:
        return context.l10n.categories;
      case FinanceTab.scheduledPayments:
        return context.l10n.scheduledPayments;
    }
  }
}

extension FinanceTabSegments on List<FinanceTab> {
  /// Сегменты для [SegmentedControl].
  List<SegmentItem<FinanceTab>> toSegmentItems(BuildContext context) {
    return map(
      (tab) => SegmentItem(value: tab, label: tab.label(context)),
    ).toList();
  }
}
