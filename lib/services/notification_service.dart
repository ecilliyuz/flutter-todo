import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo_model.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // İzinleri kontrol et ve iste
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android için izinleri kontrol et
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // iOS için izinleri kontrol et
    await _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleTodoReminder(Todo todo) async {
    if (todo.reminderDate == null || todo.id == null) return;

    try {
      final now = DateTime.now();
      if (todo.reminderDate!.isBefore(now)) return;

      AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
        'todo_reminders',
        'Todo Hatırlatıcıları',
        channelDescription: 'Yapılacak görevler için hatırlatıcılar',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        playSound: true,
      );

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Tek seferlik bildirim
      if (todo.reminderType == 'once') {
        await _notifications.zonedSchedule(
          todo.id!,
          'Görev Hatırlatıcısı',
          todo.title,
          tz.TZDateTime.from(todo.reminderDate!, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      // Günlük bildirim
      else if (todo.reminderType == 'daily') {
        await _notifications.zonedSchedule(
          todo.id!,
          'Günlük Görev Hatırlatıcısı',
          todo.title,
          _nextInstanceOfTime(todo.reminderDate!),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      // Haftalık bildirim
      else if (todo.reminderType == 'weekly') {
        await _notifications.zonedSchedule(
          todo.id!,
          'Haftalık Görev Hatırlatıcısı',
          todo.title,
          _nextInstanceOfTime(todo.reminderDate!),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e) {
      debugPrint('Bildirim planlanırken hata oluştu: $e');
      rethrow;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime reminderDate) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderDate.hour,
      reminderDate.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
