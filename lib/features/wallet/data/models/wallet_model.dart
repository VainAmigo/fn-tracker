class WalletModel {
  final String? id;
  final String name;
  final String colorId;
  final String iconId;
  final double? balance;
  final bool? isDefault;

  WalletModel({
    this.id,
    required this.name,
    required this.colorId,
    required this.iconId,
    this.balance,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorId': colorId,
      'iconId': iconId,
      'balance': balance,
      'isDefault': isDefault,
    };
  }

  WalletModel copyWith({
    String? id,
    String? name,
    String? colorId,
    String? iconId,
    double? balance,
    bool? isDefault,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorId: colorId ?? this.colorId,
      iconId: iconId ?? this.iconId,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      name: json['name'],
      colorId: json['colorId'],
      iconId: json['iconId'],
      balance: (json['balance'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
