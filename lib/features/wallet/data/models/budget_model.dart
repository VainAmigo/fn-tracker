class BudgetModel {
  final String id;
  final double amount;

  BudgetModel({required this.id, required this.amount});

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
