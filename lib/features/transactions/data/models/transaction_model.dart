import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String? categoryId;
  final String? walletId;
  final String? goalId;
  final double amount;
  final String note;
  final DateTime? createdAt;
  final TransactionType type;
  final String dayKey;
  final String periodKey;

  TransactionModel({
    required this.id,
    this.categoryId,
    this.walletId,
    this.goalId,
    required this.amount,
    required this.note,
    this.createdAt,
    required this.type,
    required this.dayKey,
    required this.periodKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'walletId': walletId,
      'goalId': goalId,
      'amount': amount,
      'note': note,
      'createdAt': createdAt!.toIso8601String(),
      'type': type.toJson(),
      'dayKey': dayKey,
      'periodKey': periodKey,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final DateTime? createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
        ? createdAtRaw
        : createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw)
        : null;

    return TransactionModel(
      id: json['id'],
      categoryId: json['categoryId'],
      walletId: json['walletId'],
      goalId: json['goalId'],
      dayKey: json['dayKey'],
      periodKey: json['periodKey'],
      amount: json['amount'],
      note: json['note'],
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      type: TransactionType.fromJson(json['type'] as String),
    );
  }
}

enum TransactionType {
  expense,
  income;

  /// Возвращает строковое представление для сохранения в Firestore
  String toJson() => name.toUpperCase();

  /// Создаёт enum из строки (например, из Firestore)
  static TransactionType fromJson(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => TransactionType.expense, // значение по умолчанию
    );
  }
}

class HomePageStatModel {
  final double totalExpense;
  final List<double> homeChartStat;

  HomePageStatModel({required this.totalExpense, required this.homeChartStat});

  Map<String, dynamic> toJson() {
    return {'totalExpense': totalExpense, 'homeChartStat': homeChartStat};
  }

  factory HomePageStatModel.fromJson(Map<String, dynamic> json) {
    return HomePageStatModel(
      totalExpense: json['totalExpense'] as double,
      homeChartStat: List<double>.from(json['homeChartStat']),
    );
  }
}
