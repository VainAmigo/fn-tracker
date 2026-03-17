import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/generated/app_localizations.dart';
import 'package:fn_tracker/components/cards/empty_card_widget.dart';

/// Виджет пустого состояния для списка транзакций.
/// Использует локализованные строки.
class EmptyTransactionsWidget extends StatelessWidget {
  const EmptyTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyCardWidget(
      title: l10n.noTransactions,
      subtitle: l10n.noTransactionsSubtitle,
    );
  }
}
