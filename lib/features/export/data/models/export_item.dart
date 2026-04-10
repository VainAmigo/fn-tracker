import 'package:fn_tracker/features/features.dart';

class ExportItem {
  const ExportItem({
    required this.transactionId,
    required this.date,
    required this.createdAt,
    required this.type,
    required this.amount,
    required this.currency,
    required this.note,
    required this.categoryName,
    required this.walletName,
    required this.goalName,
    required this.dayKey,
    required this.periodKey,
  });

  final String transactionId;
  final DateTime date;
  final DateTime createdAt;
  final TransactionType type;
  final double amount;
  final String? currency;
  final String? note;
  final String? categoryName;
  final String? walletName;
  final String? goalName;
  final String dayKey;
  final String periodKey;
}
