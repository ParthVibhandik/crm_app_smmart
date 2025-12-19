import 'package:flutex_admin/features/task/model/task_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TaskReminderService {
  final FlutterLocalNotificationsPlugin fln;

  TaskReminderService(this.fln);

  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (task.dueDate == null) return;

    final dueDate = DateTime.parse(task.dueDate!);
    final reminderDate = dueDate.subtract(const Duration(hours: 1));

    if (reminderDate.isBefore(DateTime.now())) return;

    tz.initializeTimeZones();
    
    await fln.zonedSchedule(
      int.parse(task.id ?? '0'),
      'Task Reminder',
      'Task "${task.name}" is due in 1 hour',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task_${task.id}',
    );
  }

  Future<void> cancelReminder(String taskId) async {
    await fln.cancel(int.parse(taskId));
  }
}
