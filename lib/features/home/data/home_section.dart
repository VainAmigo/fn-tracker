import 'package:flutter/widgets.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Блоки списка на главном экране (порядок и видимость в [HomeLayoutSettingsCubit]).
enum HomeSection {
  budget,
  wallets,
  quickCategories,
  lastTransactions,
}

extension HomeSectionX on HomeSection {
  String label(BuildContext context) {
    return switch (this) {
      HomeSection.budget => context.l10n.budget,
      HomeSection.wallets => context.l10n.wallets,
      HomeSection.quickCategories => context.l10n.quickCategories,
      HomeSection.lastTransactions => context.l10n.lastTransactions,
    };
  }

  String get storageKey => name;
}
