// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

// Donner un alias au package pour éviter le conflit
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    tz.initializeTimeZones();
    
    _plugin = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    
    await _plugin.initialize(settings);
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null) return;
    
    final scheduledDate = tz.TZDateTime.from(
      task.dueDate!.subtract(const Duration(hours: 1)),
      tz.local,
    );
    
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'task_reminder_channel',
      'Rappels de tâches',
      channelDescription: 'Notifications pour les rappels de tâches',
      importance: Importance.high,
      priority: notifications.Priority.high,  // ← Utiliser l'alias !
    );
    
    const NotificationDetails details = NotificationDetails(android: android);
    
    await _plugin.zonedSchedule(
      task.id.hashCode,
      '📋 Rappel : ${task.title}',
      'Cette tâche est due dans 1 heure',
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(String taskId) async {
    await _plugin.cancel(taskId.hashCode);
  }
}