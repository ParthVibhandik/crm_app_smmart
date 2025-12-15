import 'package:dio/dio.dart';
import 'attendance_status.dart';

class AttendanceService {
  final Dio _dio;

  AttendanceService(String token)
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://smmartcrm.in',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

  Future<AttendanceStatus> getTodayStatus() async {
    final response = await _dio.get('/flutex_admin_api/attendance/today');

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Failed');
    }

    return AttendanceStatus.fromJson(response.data);
  }

  Future<void> punchIn({String location = 'Office'}) async {
    final response = await _dio.post(
      '/flutex_admin_api/attendance/punch-in',
      data: {'location': location},
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Punch-in failed');
    }
  }

  Future<void> punchOut() async {
    final response = await _dio.post('/flutex_admin_api/attendance/punch-out');

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Punch-out failed');
    }
  }
}
