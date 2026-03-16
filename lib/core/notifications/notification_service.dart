import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Сервис локальных уведомлений для плановых платежей.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'scheduled_payments_reminders';
  static const String _channelName = 'Напоминания о платежах';

  static bool _initialized = false;

  /// Инициализация. Вызывать при старте приложения.
  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Напоминания о предстоящих плановых платежах',
            importance: Importance.defaultImportance,
          ),
        );
    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final paymentId = data['scheduledPaymentId'] as String?;
        if (paymentId != null) {
          // Можно навигировать к деталям платежа через GoRouter/Navigator
        }
      } catch (_) {}
    }
  }

  static int _notificationId(String paymentId) {
    return paymentId.hashCode.abs() % 2147483647;
  }

  /// Планирует напоминание для платежа.
  static Future<void> scheduleReminder(ScheduledPaymentModel payment) async {
    if (!payment.reminderEnabled || payment.reminderOption == null) return;
    if (payment.isPaused) return;

    await cancelReminder(payment.id);

    final nextDate = ScheduledPaymentDateService.computeNextDateForModel(payment);
    if (nextDate == null) return;

    final hour = payment.reminderHour ?? 9;
    final minute = payment.reminderMinute ?? 0;
    final reminderDate = _reminderDate(
      nextDate,
      payment.reminderOption!,
      hour: hour,
      minute: minute,
    );
    if (reminderDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Напоминания о предстоящих плановых платежах',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _notificationId(payment.id),
      'Плановый платёж: ${payment.name}',
      'Сумма: ${payment.amount.toStringAsFixed(0)}. Дата: ${nextDate.day.toString().padLeft(2, '0')}.${nextDate.month.toString().padLeft(2, '0')}.${nextDate.year}',
      reminderDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'scheduledPaymentId': payment.id}),
    );
  }

  static tz.TZDateTime _reminderDate(
    DateTime paymentDate,
    ScheduledReminderOption option, {
    int hour = 9,
    int minute = 0,
  }) {
    final local = tz.TZDateTime.from(
      DateTime(paymentDate.year, paymentDate.month, paymentDate.day, hour, minute),
      tz.local,
    );
    return switch (option) {
      ScheduledReminderOption.onTheDay => local,
      ScheduledReminderOption.oneDayBefore => local.subtract(const Duration(days: 1)),
      ScheduledReminderOption.twoDaysBefore => local.subtract(const Duration(days: 2)),
      ScheduledReminderOption.threeDaysBefore => local.subtract(const Duration(days: 3)),
      ScheduledReminderOption.oneWeekBefore => local.subtract(const Duration(days: 7)),
    };
  }

  /// Отменяет напоминание.
  static Future<void> cancelReminder(String paymentId) async {
    await _plugin.cancel(_notificationId(paymentId));
  }

  /// Перепланирует все напоминания (при старте приложения).
  static Future<void> rescheduleAll(
    List<ScheduledPaymentModel> payments,
  ) async {
    for (final p in payments) {
      await scheduleReminder(p);
    }
  }
}
