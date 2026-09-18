import 'package:cloud_firestore/cloud_firestore.dart';

/// Тип лимита категории относительно месячного бюджета.
enum CategoryLimitType {
  none,
  fixed,
  percent;

  String toJson() => name;

  static CategoryLimitType fromJson(String? value, {double? limitValue}) {
    if (value == null || value.isEmpty) {
      // Миграция: старые записи с limitValue без типа → fixed.
      if (limitValue != null && limitValue > 0) return CategoryLimitType.fixed;
      return CategoryLimitType.none;
    }
    return CategoryLimitType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoryLimitType.none,
    );
  }
}

class CategoryModel {
  final String categoryId;
  final String colorId;
  final DateTime? createdAt;
  final bool? isQuick;
  final String iconId;
  final CategoryLimitType limitType;
  final double? limitValue;
  final String name;

  CategoryModel({
    required this.categoryId,
    required this.colorId,
    this.createdAt,
    this.isQuick,
    required this.iconId,
    this.limitType = CategoryLimitType.none,
    this.limitValue,
    required this.name,
  });

  bool get hasLimit =>
      limitType != CategoryLimitType.none &&
      limitValue != null &&
      limitValue! > 0;

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'colorId': colorId,
      'createdAt': createdAt?.toIso8601String(),
      'isQuick': isQuick ?? false,
      'iconId': iconId,
      'limitType': limitType.toJson(),
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

    final limitValue = (json['limitValue'] as num?)?.toDouble();

    return CategoryModel(
      categoryId: json['categoryId'],
      colorId: json['colorId'],
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      isQuick: json['isQuick'] as bool?,
      iconId: json['iconId'],
      limitType: CategoryLimitType.fromJson(
        json['limitType'] as String?,
        limitValue: limitValue,
      ),
      limitValue: limitValue,
      name: json['name'],
    );
  }

  CategoryModel copyWith({
    String? categoryId,
    String? colorId,
    DateTime? createdAt,
    bool? isQuick,
    String? iconId,
    CategoryLimitType? limitType,
    double? limitValue,
    bool clearLimitValue = false,
    String? name,
  }) {
    return CategoryModel(
      categoryId: categoryId ?? this.categoryId,
      colorId: colorId ?? this.colorId,
      createdAt: createdAt ?? this.createdAt,
      isQuick: isQuick ?? this.isQuick,
      iconId: iconId ?? this.iconId,
      limitType: limitType ?? this.limitType,
      limitValue: clearLimitValue ? null : (limitValue ?? this.limitValue),
      name: name ?? this.name,
    );
  }
}
