import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/l10n/generated/app_localizations.dart';
import 'package:fn_tracker/features/export/data/models/export_item.dart';

enum ExportColumn {
  date,
  createdAt,
  type,
  amount,
  currency,
  category,
  wallet,
  note,
  transactionId;

  String title(AppLocalizations l10n) {
    return switch (this) {
      date => l10n.exportColumnDate,
      createdAt => l10n.exportColumnCreatedAt,
      type => l10n.exportColumnType,
      amount => l10n.exportColumnAmount,
      currency => l10n.exportColumnCurrency,
      category => l10n.exportColumnCategory,
      wallet => l10n.exportColumnWallet,
      note => l10n.exportColumnNote,
      transactionId => l10n.exportColumnTransactionId,
    };
  }

  String description(AppLocalizations l10n) {
    return switch (this) {
      date => l10n.exportColumnDateDescription,
      createdAt => l10n.exportColumnCreatedAtDescription,
      type => l10n.exportColumnTypeDescription,
      amount => l10n.exportColumnAmountDescription,
      currency => l10n.exportColumnCurrencyDescription,
      category => l10n.exportColumnCategoryDescription,
      wallet => l10n.exportColumnWalletDescription,
      note => l10n.exportColumnNoteDescription,
      transactionId => l10n.exportColumnTransactionIdDescription,
    };
  }

  String valueFrom(ExportItem item) {
    return switch (this) {
      date => item.date.formatDotDate,
      createdAt => item.createdAt.formatDotDate,
      type => item.type.name,
      amount => item.amount.toStringAsFixed(2),
      currency => item.currency ?? '',
      category => item.categoryName ?? '',
      wallet => item.walletName ?? '',
      note => item.note ?? '',
      transactionId => item.transactionId,
    };
  }

  static List<ExportColumn> get defaultOrder => const [
    ExportColumn.date,
    ExportColumn.type,
    ExportColumn.amount,
    ExportColumn.category,
    ExportColumn.wallet,
    ExportColumn.note,
  ];
}
