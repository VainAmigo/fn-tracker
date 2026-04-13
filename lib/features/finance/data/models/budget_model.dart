import 'package:cloud_firestore/cloud_firestore.dart';

/// Бюджет всегда месячный. [amount] — сумма на месяц.
class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.amount,
    this.canSpendAmount,
  });

  final String id;
  final double amount;
  final double? canSpendAmount;

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

class BudgetHistoryEntry {
  const BudgetHistoryEntry({
    required this.id,
    required this.amount,
    required this.effectiveDayKey,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String effectiveDayKey;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'effectiveDayKey': effectiveDayKey,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory BudgetHistoryEntry.fromJson(String id, Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final DateTime createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.tryParse(createdAtRaw as String? ?? '') ?? DateTime.now();

    return BudgetHistoryEntry(
      id: id,
      amount: (json['amount'] as num).toDouble(),
      effectiveDayKey: json['effectiveDayKey'] as String,
      createdAt: createdAt,
    );
  }

  BudgetModel toBudgetModel(String budgetId) {
    return BudgetModel(id: budgetId, amount: amount);
  }
}
