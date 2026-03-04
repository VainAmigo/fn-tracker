import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String categoryId;
  final double amount;
  final String note;
  final DateTime createdAt;
  final String currency;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.currency,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'currency': currency,
      'type': type.toJson(),
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
      amount: json['amount'],
      note: json['note'],
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      currency: json['currency'],
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
