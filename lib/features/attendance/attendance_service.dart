import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'attendance_status.dart';
import 'biometric_service.dart';
import 'camera_service.dart';

class AttendanceService {
  final Dio _dio;
  final BiometricService _biometric = BiometricService();
  final CameraService _camera = CameraService();

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

  /// ==============================
  /// TODAY STATUS
  /// ==============================
  Future<AttendanceStatus> getTodayStatus() async {
    final response = await _dio.get('/flutex_admin_api/attendance/today');

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Failed');
    }

    final attendanceId = response.data['attendance_id'];
    final tokenHeader = _dio.options.headers['Authorization']?.toString();

    // Persist only if active attendance exists
    if (attendanceId != null &&
        attendanceId.toString().isNotEmpty &&
        tokenHeader != null &&
        tokenHeader.isNotEmpty) {
      final token = tokenHeader.replaceAll('Bearer ', '');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('attendance_id', attendanceId.toString());
      await prefs.setString('token', token);
    }

    return AttendanceStatus.fromJson(response.data);
  }

  /// ==============================
  /// LOCATION (SINGLE SHOT ONLY)
  /// ==============================
  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission required to mark attendance.');
    }

    // 🔒 IMPORTANT: For background tracking, enforce ALWAYS
    if (permission == LocationPermission.whileInUse) {
      throw Exception(
        'Please allow location access "Always" to enable attendance tracking.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// ==============================
  /// PUNCH IN
  /// ==============================
  Future<void> punchIn() async {
    // 1️⃣ Biometric
    final biometricAvailable = await _biometric.isBiometricAvailable();
    if (biometricAvailable) {
      final authenticated = await _biometric.authenticate(
        'Authenticate to punch in',
      );
      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    // 2️⃣ Selfie
    final XFile? photo = await _camera.takeSelfie(maxWidth: 600);

    if (photo == null) {
      throw Exception('Selfie is required to punch in');
    }

    // 3️⃣ Location (single fetch)
    final Position position = await _getCurrentLocation();

    // 4️⃣ API
    final FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        photo.path,
        filename: photo.path.split('/').last,
      ),
      'punch_time': DateTime.now().toIso8601String(),
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    final response = await _dio.post(
      '/flutex_admin_api/attendance/punch-in',
      data: formData,
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Punch-in failed');
    }

    // ==============================
    // START BACKGROUND TRACKING
    // ==============================
    final int attendanceId = response.data['attendance_id'];
    final String token = _dio.options.headers['Authorization']!
        .toString()
        .replaceAll('Bearer ', '');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_id', attendanceId.toString());
    await prefs.setString('token', token);

    final service = FlutterBackgroundService();

    // Restart service cleanly
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stop');
      await Future.delayed(const Duration(seconds: 1));
    }

    await service.startService();
  }

  /// ==============================
  /// PUNCH OUT
  /// ==============================
  Future<void> punchOut() async {
    // 1️⃣ Biometric
    final biometricAvailable = await _biometric.isBiometricAvailable();
    if (biometricAvailable) {
      final authenticated = await _biometric.authenticate(
        'Authenticate to punch out',
      );
      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    // 2️⃣ Location (single fetch)
    final Position position = await _getCurrentLocation();

    // 3️⃣ API
    final FormData formData = FormData.fromMap({
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
    });

    final response = await _dio.post(
      '/flutex_admin_api/attendance/punch-out',
      data: formData,
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Punch-out failed');
    }

    // ==============================
    // STOP BACKGROUND TRACKING
    // ==============================
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendance_id');
    await prefs.remove('token');

    final service = FlutterBackgroundService();
    service.invoke('stop');
  }
}
