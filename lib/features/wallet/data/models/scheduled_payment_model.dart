/// Тип планового платежа.
enum ScheduledPaymentType {
  subscription('Подписка'),
  regular('Регулярный платёж');

  const ScheduledPaymentType(this.label);
  final String label;
}

/// Частота планового платежа.
enum ScheduledPaymentFrequency {
  day('Day'),
  monthly('Ежемесячно'),
  yearly('Ежегодно');

  const ScheduledPaymentFrequency(this.label);
  final String label;
}

/// Mock-модель планового платежа для UI.
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
}
