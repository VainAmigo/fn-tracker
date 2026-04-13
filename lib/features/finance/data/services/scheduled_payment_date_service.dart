import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';

/// Сервис вычисления следующей даты платежа.
class ScheduledPaymentDateService {
  ScheduledPaymentDateService._();

  static const int _endOfMonthDay = 31;

  /// Вычисляет следующую дату платежа по заданным параметрам.
  static DateTime? calculateNextDate({
    required ScheduledPaymentFrequency frequency,
    DateTime? paymentDate,
    List<int>? monthDays,
    List<String>? yearlyDates,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateUtils.dateOnly(now);

    switch (frequency) {
      case ScheduledPaymentFrequency.oneTime:
        if (paymentDate == null) return null;
        final d = DateUtils.dateOnly(paymentDate);
        return d.isBefore(today) ? null : d;

      case ScheduledPaymentFrequency.monthly:
        if (monthDays == null || monthDays.isEmpty) return null;
        DateTime? minDate;
        for (final day in monthDays) {
          final next = _nextDayOfMonth(day, now);
          if (minDate == null || next.isBefore(minDate)) {
            minDate = next;
          }
        }
        return minDate;

      case ScheduledPaymentFrequency.yearly:
        if (yearlyDates == null || yearlyDates.isEmpty) return null;
        DateTime? minDate;
        for (final md in yearlyDates) {
          final parsed = _parseMonthDay(md);
          if (parsed == null) continue;
          final next = _nextYearlyDate(parsed.$1, parsed.$2, now);
          if (minDate == null || next.isBefore(minDate)) {
            minDate = next;
          }
        }
        return minDate;
    }
  }

  /// Вычисляет nextDate для модели (по сохранённым полям).
  static DateTime? computeNextDateForModel(ScheduledPaymentModel model) {
    return calculateNextDate(
      frequency: model.frequency,
      paymentDate: model.paymentDate,
      monthDays: model.monthDays,
      yearlyDates: model.yearlyDates,
    );
  }

  /// Возвращает все дни в указанном месяце, когда платеж должен происходить.
  static List<int> getDaysInMonthForPayment(
    ScheduledPaymentModel payment,
    int year,
    int month,
  ) {
    final result = <int>{};
    final lastDay = DateTime(year, month + 1, 0).day;

    switch (payment.frequency) {
      case ScheduledPaymentFrequency.oneTime:
        if (payment.paymentDate != null) {
          final d = payment.paymentDate!;
          if (d.year == year && d.month == month) {
            result.add(d.day);
          }
        }
        break;

      case ScheduledPaymentFrequency.monthly:
        if (payment.monthDays != null) {
          for (final day in payment.monthDays!) {
            if (day == _endOfMonthDay) {
              result.add(lastDay);
            } else if (day <= lastDay) {
              result.add(day.clamp(1, lastDay));
            }
          }
        }
        break;

      case ScheduledPaymentFrequency.yearly:
        if (payment.yearlyDates != null) {
          for (final md in payment.yearlyDates!) {
            final parsed = _parseMonthDay(md);
            if (parsed == null) continue;
            final (m, d) = parsed;
            if (m == month) {
              final actualDay = d == _endOfMonthDay ? lastDay : d.clamp(1, lastDay);
              result.add(actualDay);
            }
          }
        }
        break;
    }
    return result.toList()..sort();
  }

  static DateTime _nextDayOfMonth(int day, DateTime reference) {
    final today = DateUtils.dateOnly(reference);
    if (day == _endOfMonthDay) {
      var d = DateTime(reference.year, reference.month + 1, 0);
      d = DateUtils.dateOnly(d);
      if (d.isBefore(today)) {
        d = DateUtils.dateOnly(
          DateTime(reference.year, reference.month + 2, 0),
        );
      }
      return d;
    }
    var d = DateTime(reference.year, reference.month, day.clamp(1, 28));
    d = DateUtils.dateOnly(d);
    if (d.isBefore(today)) {
      d = DateUtils.dateOnly(
        DateTime(reference.year, reference.month + 1, day.clamp(1, 28)),
      );
    }
    return d;
  }

  static DateTime _nextYearlyDate(int month, int day, DateTime reference) {
    final today = DateUtils.dateOnly(reference);
    var d = DateTime(reference.year, month, day.clamp(1, 28));
    d = DateUtils.dateOnly(d);
    if (d.isBefore(today)) {
      d = DateUtils.dateOnly(
        DateTime(reference.year + 1, month, day.clamp(1, 28)),
      );
    }
    return d;
  }

  /// Парсит "MM-dd" в (month, day).
  static (int, int)? _parseMonthDay(String md) {
    final parts = md.split('-');
    if (parts.length != 2) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    if (month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return (month, day);
  }
}
