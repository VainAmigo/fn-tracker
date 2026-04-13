import 'package:cloud_firestore/cloud_firestore.dart';

/// Тип планового платежа.
enum ScheduledPaymentType {
  subscription('Подписка'),
  regular('Регулярный платёж'),
  regularIncome('Регулярный доход');

  const ScheduledPaymentType(this.label);
  final String label;

  static ScheduledPaymentType fromJson(String value) {
    return ScheduledPaymentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScheduledPaymentType.regular,
    );
  }

  String toJson() => name;
}

/// Частота планового платежа.
enum ScheduledPaymentFrequency {
  oneTime('Единожды'),
  monthly('Ежемесячно'),
  yearly('Ежегодно');

  const ScheduledPaymentFrequency(this.label);
  final String label;

  static ScheduledPaymentFrequency fromJson(String value) {
    return ScheduledPaymentFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScheduledPaymentFrequency.monthly,
    );
  }

  String toJson() => name;
}

/// Модель планового платежа.
class ScheduledPaymentModel {
  const ScheduledPaymentModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.nextDate,
    required this.iconId,
    required this.colorId,
    required this.type,
    required this.frequency,
    this.frequencyInterval,
    required this.autoCreateTransaction,
    this.isPaused = false,
    this.walletId,
    this.goalId,
    this.categoryId,
    this.paymentDate,
    this.monthDays,
    this.yearlyDates,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double amount;
  final DateTime nextDate;
  final String iconId;
  final String colorId;
  final ScheduledPaymentType type;
  final ScheduledPaymentFrequency frequency;
  final int? frequencyInterval;
  final bool autoCreateTransaction;
  final bool isPaused;
  final String? walletId;
  final String? goalId;
  final String? categoryId;
  final DateTime? paymentDate;
  final List<int>? monthDays;
  final List<String>? yearlyDates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScheduledPaymentModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? nextDate,
    String? iconId,
    String? colorId,
    ScheduledPaymentType? type,
    ScheduledPaymentFrequency? frequency,
    int? frequencyInterval,
    bool? autoCreateTransaction,
    bool? isPaused,
    String? walletId,
    String? goalId,
    String? categoryId,
    DateTime? paymentDate,
    List<int>? monthDays,
    List<String>? yearlyDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduledPaymentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      nextDate: nextDate ?? this.nextDate,
      iconId: iconId ?? this.iconId,
      colorId: colorId ?? this.colorId,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      frequencyInterval: frequencyInterval ?? this.frequencyInterval,
      autoCreateTransaction:
          autoCreateTransaction ?? this.autoCreateTransaction,
      isPaused: isPaused ?? this.isPaused,
      walletId: walletId ?? this.walletId,
      goalId: goalId ?? this.goalId,
      categoryId: categoryId ?? this.categoryId,
      paymentDate: paymentDate ?? this.paymentDate,
      monthDays: monthDays ?? this.monthDays,
      yearlyDates: yearlyDates ?? this.yearlyDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'nextDate': Timestamp.fromDate(nextDate),
      'iconId': iconId,
      'colorId': colorId,
      'type': type.toJson(),
      'frequency': frequency.toJson(),
      'frequencyInterval': frequencyInterval,
      'autoCreateTransaction': autoCreateTransaction,
      'isPaused': isPaused,
      'walletId': walletId,
      'goalId': goalId,
      'categoryId': categoryId,
      'paymentDate':
          paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'monthDays': monthDays,
      'yearlyDates': yearlyDates,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ScheduledPaymentModel.fromJson(Map<String, dynamic> json) {
    final nextDateRaw = json['nextDate'];
    final DateTime nextDate = nextDateRaw is Timestamp
        ? nextDateRaw.toDate()
        : (nextDateRaw is String
            ? DateTime.parse(nextDateRaw)
            : DateTime.now());

    final paymentDateRaw = json['paymentDate'];
    final DateTime? paymentDate = paymentDateRaw == null
        ? null
        : paymentDateRaw is Timestamp
            ? paymentDateRaw.toDate()
            : DateTime.tryParse(paymentDateRaw.toString());

    final createdAtRaw = json['createdAt'];
    final DateTime? createdAt = createdAtRaw == null
        ? null
        : createdAtRaw is Timestamp
            ? createdAtRaw.toDate()
            : null;

    final updatedAtRaw = json['updatedAt'];
    final DateTime? updatedAt = updatedAtRaw == null
        ? null
        : updatedAtRaw is Timestamp
            ? updatedAtRaw.toDate()
            : null;

    final monthDaysRaw = json['monthDays'];
    final List<int>? monthDays = monthDaysRaw is List
        ? (monthDaysRaw).map((e) => (e as num).toInt()).toList()
        : null;

    final yearlyDatesRaw = json['yearlyDates'];
    final List<String>? yearlyDates = yearlyDatesRaw is List
        ? (yearlyDatesRaw).map((e) => e.toString()).toList()
        : null;

    return ScheduledPaymentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      nextDate: nextDate,
      iconId: json['iconId'] as String,
      colorId: json['colorId'] as String,
      type: ScheduledPaymentType.fromJson(json['type'] as String? ?? 'regular'),
      frequency: ScheduledPaymentFrequency.fromJson(
        json['frequency'] as String? ?? 'monthly',
      ),
      frequencyInterval: (json['frequencyInterval'] as num?)?.toInt(),
      autoCreateTransaction: json['autoCreateTransaction'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      walletId: json['walletId'] as String?,
      goalId: json['goalId'] as String?,
      categoryId: json['categoryId'] as String?,
      paymentDate: paymentDate,
      monthDays: monthDays,
      yearlyDates: yearlyDates,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
