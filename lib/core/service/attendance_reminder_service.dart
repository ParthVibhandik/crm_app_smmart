import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AttendanceReminderService {
  final FlutterLocalNotificationsPlugin fln;

  AttendanceReminderService(this.fln);

  Future<void> showGeofenceAlert(bool entered) async {
    await fln.show(
      999, // Static ID for geofence alerts
      entered ? 'Office Zone Entered' : 'Office Zone Exited',
      entered 
          ? 'Don\'t forget to punch in for your attendance!' 
          : 'Don\'t forget to punch out before you leave!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_reminders',
          'Attendance Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
