class WalletModel {
  final String? id;
  final String name;
  final String colorId;
  final String iconId;
  final double? balance;
  final bool isDefault;

  /// Скрыть только сумму (карточка видна, баланс показывается как ••••).
  final bool hideAmount;

  /// Скрыть весь кошелёк (показывается только в блоке «Скрытые карточки»).
  final bool isHidden;

  WalletModel({
    this.id,
    required this.name,
    required this.colorId,
    required this.iconId,
    this.balance,
    required this.isDefault,
    this.hideAmount = false,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorId': colorId,
      'iconId': iconId,
      'balance': balance,
      'isDefault': isDefault,
      'hideAmount': hideAmount,
      'isHidden': isHidden,
    };
  }

  WalletModel copyWith({
    String? id,
    String? name,
    String? colorId,
    String? iconId,
    double? balance,
    bool? isDefault,
    bool? hideAmount,
    bool? isHidden,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorId: colorId ?? this.colorId,
      iconId: iconId ?? this.iconId,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
      hideAmount: hideAmount ?? this.hideAmount,
      isHidden: isHidden ?? this.isHidden,
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
      hideAmount: json['hideAmount'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }
}
