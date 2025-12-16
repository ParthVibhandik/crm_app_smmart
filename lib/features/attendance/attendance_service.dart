import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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

  /// Get today's attendance status
  Future<AttendanceStatus> getTodayStatus() async {
    final response = await _dio.get('/flutex_admin_api/attendance/today');

    if (response.data['status'] != true) {
      throw Exception(response.data['message'] ?? 'Failed');
    }

    return AttendanceStatus.fromJson(response.data);
  }

  /// Get high-accuracy GPS location
  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Enable them from settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Punch In (Biometric + Selfie + GPS required)
  Future<void> punchIn() async {
    // 1. Biometric Authentication
    final biometricAvailable = await _biometric.isBiometricAvailable();
    if (biometricAvailable) {
      final authenticated =
          await _biometric.authenticate('Authenticate to punch in');
      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    // 2. Selfie Capture
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 600,
    );

    if (photo == null) {
      throw Exception('Selfie is required to punch in');
    }

    // 3. Location Capture
    final Position position = await _getCurrentLocation();

    // 4. Send to Backend
    final String fileName = photo.path.split('/').last;

    final FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
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
  }

  /// Punch Out (Biometric + GPS required)
  Future<void> punchOut() async {
    // 1. Biometric Authentication
    final biometricAvailable = await _biometric.isBiometricAvailable();
    if (biometricAvailable) {
      final authenticated =
          await _biometric.authenticate('Authenticate to punch out');
      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    // 2. Location Capture
    final Position position = await _getCurrentLocation();

    // 3. Send to Backend
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
  }
}
