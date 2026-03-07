import 'package:fn_tracker/components/components.dart';

/// Табы экрана кошелька. Единый источник истины для переключателя и контента.
enum WalletTab {
  budget,
  wallet,
  goals,
}

extension WalletTabX on WalletTab {
  String get label {
    switch (this) {
      case WalletTab.budget:
        return 'Budget';
      case WalletTab.wallet:
        return 'Wallet';
      case WalletTab.goals:
        return 'Goals';
    }
  }
}

extension WalletTabSegments on List<WalletTab> {
  /// Сегменты для [SegmentedControl].
  List<SegmentItem<WalletTab>> toSegmentItems() {
    return map((tab) => SegmentItem(value: tab, label: tab.label)).toList();
  }
}
