import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id;
  final String name;
  final String colorId;
  final String iconId;
  final double? balance;
  final DateTime? createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.colorId,
    required this.iconId,
    this.balance,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorId': colorId,
      'iconId': iconId,
      'balance': balance,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final DateTime? createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
            ? createdAtRaw
            : createdAtRaw is String
                ? DateTime.tryParse(createdAtRaw)
                : null;

    return WalletModel(
      id: json['id'],
      name: json['name'],
      colorId: json['colorId'],
      iconId: json['iconId'],
      balance: (json['balance'] as num?)?.toDouble(),
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
