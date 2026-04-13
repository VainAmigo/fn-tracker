import 'package:fn_tracker/components/components.dart';

/// Табы экрана «Финансы». Единый источник истины для переключателя и контента.
enum FinanceTab { budget, accounts, categories, scheduledPayments }

extension FinanceTabX on FinanceTab {
  String get label {
    switch (this) {
      case FinanceTab.budget:
        return 'Budget';
      case FinanceTab.accounts:
        return 'Accounts';
      case FinanceTab.categories:
        return 'Categories';
      case FinanceTab.scheduledPayments:
        return 'Scheduled Payments';
    }
  }
}

extension FinanceTabSegments on List<FinanceTab> {
  /// Сегменты для [SegmentedControl].
  List<SegmentItem<FinanceTab>> toSegmentItems() {
    return map((tab) => SegmentItem(value: tab, label: tab.label)).toList();
  }
}
