class BudgetModel {
  final String id;
  final double amount;
  final BudgetType type;
  final double? canSpendAmount;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.type,
    this.canSpendAmount,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'type': type.toJson()};
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: BudgetType.fromJson(json['type'] as String? ?? 'MONTHLY'),
    );
  }
}

enum BudgetType {
  yearly,
  monthly,
  weekly;

  /// Возвращает строковое представление для сохранения в Firestore
  String toJson() => name.toUpperCase();

  /// Создаёт enum из строки (например, из Firestore)
  static BudgetType fromJson(String value) {
    return BudgetType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BudgetType.yearly, // значение по умолчанию
    );
  }
}
