import 'package:dio/dio.dart';
import 'attendance_status.dart';
import 'biometric_service.dart';

class AttendanceService {
  final Dio _dio;
  final BiometricService _biometric = BiometricService();

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

  // Punch In (Biometric REQUIRED if available)
  Future<void> punchIn({String location = 'Office'}) async {
    final biometricAvailable = await _biometric.isBiometricAvailable();

    if (biometricAvailable) {
      final authenticated = await _biometric.authenticate(
        'Authenticate to punch in',
      );

      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    // face capture can be added here in future
    // in the request body as 'face_image'
  

    final response = await _dio.post(
      '/flutex_admin_api/attendance/punch-in',
      data: {'location': location},
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Punch-in failed');
    }

    // punched in successfully -> now start tracking location and battery info every 15 minutes 
    // TODO: Implement location and battery tracking

  }

  /// Punch Out (Biometric REQUIRED if available)
  Future<void> punchOut() async {
    final biometricAvailable = await _biometric.isBiometricAvailable();

    if (biometricAvailable) {
      final authenticated = await _biometric.authenticate(
        'Authenticate to punch out',
      );

      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    final response = await _dio.post('/flutex_admin_api/attendance/punch-out');

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Punch-out failed');
    }
  }
}
