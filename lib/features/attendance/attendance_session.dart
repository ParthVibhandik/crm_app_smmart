import 'package:shared_preferences/shared_preferences.dart';

class AttendanceSession {
  static const _attendanceIdKey = 'attendance_id';

  static Future<bool> isPunchedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final punchedIn = prefs.getString(_attendanceIdKey) != null;
    print('[AttendanceSession] isPunchedIn=$punchedIn');
    return punchedIn;
  }

  static Future<String?> getAttendanceId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_attendanceIdKey);
    print('[AttendanceSession] attendance_id=$id');
    return id;
  }
}
