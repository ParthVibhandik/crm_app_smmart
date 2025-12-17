import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Position? _lastKnownPosition;
StreamSubscription<Position>? _positionSub;

const String BASE_URL = 'https://smmartcrm.in';
const String TRACK_API = '/flutex_admin_api/attendance/track';

Future<void> initTrackingService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: trackingServiceStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'attendance_tracking',
      initialNotificationTitle: 'Attendance Tracking',
      initialNotificationContent: 'Tracking active',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: trackingServiceStart,
    ),
  );
}

@pragma('vm:entry-point')
void trackingServiceStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    // Make sure we enter true foreground mode so OEMs don't suspend the service when screen is off
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: 'Attendance Tracking',
      content: 'Location tracking running',
    );
  }

  _positionSub =
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (position) {
          _lastKnownPosition = position;
        },
        onError: (e) {
          print('[Attendance Tracking] Location stream error: $e');
        },
      );

  final dio = Dio();
  final battery = Battery();

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    try {
      // Get values from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final attendanceId = prefs.getString('attendance_id');
      final token = prefs.getString('token');

      // Debug current SharedPreferences contents to diagnose missing values
      print('[Attendance Tracking] Pref keys: ${prefs.getKeys()}');
      print(
        '[Attendance Tracking] Pref attendance_id raw: ${prefs.getString('attendance_id')}',
      );
      print(
        '[Attendance Tracking] Pref token raw exists: ${prefs.containsKey('token')}',
      );

      print('[Attendance Tracking] Timer triggered');
      print('[Attendance Tracking] Attendance ID: $attendanceId');
      print('[Attendance Tracking] Token exists: ${token != null}');

      if (attendanceId == null ||
          attendanceId.isEmpty ||
          token == null ||
          token.isEmpty) {
        print(
          '[Attendance Tracking] Missing attendance_id or token, skipping...',
        );
        return;
      }

      final position = _lastKnownPosition;

      if (position == null) {
        print('[Attendance Tracking] No GPS fix yet, skipping...');
        return;
      }

      final batteryLevel = await battery.batteryLevel ?? 0;
      final charging = (await battery.batteryState) == BatteryState.charging
          ? 1
          : 0;

      // Validate all required fields before sending
      if (position.latitude == 0.0 && position.longitude == 0.0) {
        print('[Attendance Tracking] Invalid GPS coordinates, skipping...');
        return;
      }

      final requestData = {
        'attendance_id': attendanceId,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'battery_percent': batteryLevel.toString(),
        'is_charging': charging.toString(),
      };

      print('[Attendance Tracking] Sending request to: $BASE_URL$TRACK_API');
      print('[Attendance Tracking] Request data: $requestData');
      print('[Attendance Tracking] Token: ${token.substring(0, 20)}...');

      final response = await dio.post(
        '$BASE_URL$TRACK_API',
        // Send as application/x-www-form-urlencoded so CodeIgniter's $this->input->post() can read it
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('[Attendance Tracking] Location tracked successfully');
      print('  Response status: ${response.statusCode}');
      print('  Response data: ${response.data}');
      print('  Attendance ID: $attendanceId');
      print('  Location: ${position.latitude}, ${position.longitude}');
      print(
        '  Battery: $batteryLevel% (Charging: ${charging == 1 ? 'Yes' : 'No'})',
      );
      print('  Time: ${DateTime.now()}');
    } catch (e) {
      print('[Attendance Tracking] Error: $e');
      if (e is DioException) {
        print('[Attendance Tracking] Status code: ${e.response?.statusCode}');
        print('[Attendance Tracking] Response data: ${e.response?.data}');
        print('[Attendance Tracking] Request data: ${e.requestOptions.data}');
      }
    }
  });

  service.on('stop').listen((event) {
    _positionSub?.cancel();
    _positionSub = null;
    service.stopSelf();
  });
}
