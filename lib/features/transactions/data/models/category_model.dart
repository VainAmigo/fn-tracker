import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String categoryId;
  final String colorId;
  final DateTime createdAt;
  final String currency;
  final String iconId;
  final double? limitValue;
  final String name;

  CategoryModel({
    required this.categoryId,
    required this.colorId,
    required this.createdAt,
    required this.currency,
    required this.iconId,
    this.limitValue,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'colorId': colorId,
      'createdAt': createdAt.toIso8601String(),
      'currency': currency,
      'iconId': iconId,
      'limitValue': limitValue,
      'name': name,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final DateTime? createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
            ? createdAtRaw
            : createdAtRaw is String
                ? DateTime.tryParse(createdAtRaw)
                : null;

    return CategoryModel(
      categoryId: json['categoryId'],
      colorId: json['colorId'],
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      currency: json['currency'],
      iconId: json['iconId'],
      limitValue: (json['limitValue'] as num?)?.toDouble(),
      name: json['name'],
    );
  }
}


