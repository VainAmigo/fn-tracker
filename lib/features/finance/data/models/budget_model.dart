import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fn_tracker/core/utils/date_keys_extention.dart';

/// Бюджет всегда месячный. [amount] — сумма на месяц.
class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.amount,
  });

  final String id;
  final double amount;

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount};
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

/// Запись истории бюджета, действующая с [effectiveMonthKey] (`YYYY-MM`).
class BudgetHistoryEntry {
  const BudgetHistoryEntry({
    required this.id,
    required this.amount,
    required this.effectiveMonthKey,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String effectiveMonthKey;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'effectiveMonthKey': effectiveMonthKey,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory BudgetHistoryEntry.fromJson(String id, Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final DateTime createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.tryParse(createdAtRaw as String? ?? '') ?? DateTime.now();

    final monthKey = json['effectiveMonthKey'] as String?;
    final dayKey = json['effectiveDayKey'] as String?;
    final effectiveMonthKey = monthKey ??
        (dayKey != null && dayKey.length >= 7
            ? dayKey.substring(0, 7)
            : DateTime.now().periodKey);

    return BudgetHistoryEntry(
      id: id,
      amount: (json['amount'] as num).toDouble(),
      effectiveMonthKey: effectiveMonthKey,
      createdAt: createdAt,
    );
  }
}
