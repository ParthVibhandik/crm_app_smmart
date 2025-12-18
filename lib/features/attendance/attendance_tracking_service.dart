import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:battery_plus/battery_plus.dart';

const String BASE_URL = 'https://smmartcrm.in';
const String TRACK_API = '/flutex_admin_api/attendance/track';

StreamSubscription<Position>? _positionSub;
DateTime? _lastSentAt;

Future<bool> _ensureLocationPermission(String platform) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('[$platform] Location services disabled → stopping service');
    return false;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // On iOS background tracking needs Always; fall back if only whileInUse.
  if (platform == 'IOS' && permission == LocationPermission.whileInUse) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse) {
      print('[$platform] Need "Always" location for background tracking');
      return false;
    }
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print('[$platform] Location permission denied → stopping service');
    return false;
  }

  return true;
}

/// ==============================
/// INIT
/// ==============================
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
      onBackground: trackingServiceStartIOS,
    ),
  );
}

/// ==============================
/// iOS BACKGROUND ENTRY
/// ==============================
@pragma('vm:entry-point')
Future<bool> trackingServiceStartIOS(ServiceInstance service) async {
  print('[iOS] Background entry triggered');
  trackingServiceStart(service);
  return true;
}

/// ==============================
/// SERVICE ENTRY POINT
/// ==============================
@pragma('vm:entry-point')
Future<void> trackingServiceStart(ServiceInstance service) async {
  print('[Tracking] Service started');

  _lastSentAt = null;
  await _positionSub?.cancel();

  if (service is AndroidServiceInstance) {
    print('[ANDROID] Initializing foreground service');

    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: 'Attendance Tracking',
      content: 'Tracking active',
    );

    _startLocationTracking(
      service: service,
      accuracy: LocationAccuracy.high,
      // 1 meter filter
      distanceFilter: 1,
      platform: 'ANDROID',
    );
  } else {
    print('[iOS] Initializing background tracking');

    _startLocationTracking(
      service: service,
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
      platform: 'IOS',
    );
  }

  service.on('stop').listen((event) {
    print('[Tracking] Stop signal received');
    _positionSub?.cancel();
    service.stopSelf();
  });
}

/// ==============================
/// LOCATION-BASED TRACKING
/// ==============================
Future<void> _startLocationTracking({
  required ServiceInstance service,
  required LocationAccuracy accuracy,
  required int distanceFilter,
  required String platform,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final attendanceId = prefs.getString('attendance_id');
  final token = prefs.getString('token');

  if (attendanceId == null || token == null) {
    print('[$platform] No attendance_id found → stopping service');
    service.stopSelf();
    return;
  }

  if (!await _ensureLocationPermission(platform)) {
    service.stopSelf();
    return;
  }

  print('[$platform] Starting location stream');

  final dio = Dio();
  final battery = Battery();

  _positionSub?.cancel();
  _positionSub =
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      ).listen(
        (position) async {
          print(
            '[$platform] Location update: '
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}',
          );

          final prefs = await SharedPreferences.getInstance();
          final currentAttendanceId = prefs.getString('attendance_id');
          final currentToken = prefs.getString('token');

          if (currentAttendanceId == null || currentToken == null) {
            print('[$platform] Punch-out detected → stopping tracking');
            await _positionSub?.cancel();
            service.stopSelf();
            return;
          }

          final now = DateTime.now();

          // ⏱ RATE LIMIT — 15 seconds
          if (_lastSentAt != null &&
              now.difference(_lastSentAt!).inSeconds < 15) {
            print('[$platform] Rate limited → skipping API call');
            return;
          }

          _lastSentAt = now;

          try {
            final batteryLevel = await battery.batteryLevel;
            final charging =
                (await battery.batteryState) == BatteryState.charging ? 1 : 0;

            await dio.post(
              '$BASE_URL$TRACK_API',
              data: {
                'attendance_id': currentAttendanceId,
                'latitude': position.latitude.toString(),
                'longitude': position.longitude.toString(),
                'battery_percent': batteryLevel.toString(),
                'is_charging': charging.toString(),
              },
              options: Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: {
                  'Authorization': 'Bearer $currentToken',
                  'Accept': 'application/json',
                },
              ),
            );

            print('[$platform] ✅ Tracking sent successfully');
          } on DioException catch (e) {
            print('[$platform] ❌ API error: ${e.response?.statusCode}');
            print('[$platform] ❌ Response: ${e.response?.data}');
          } catch (e) {
            print('[$platform] ❌ Unexpected error: $e');
          }
        },
        onError: (error) async {
          print('[$platform] ❌ Location stream error: $error');
          await _positionSub?.cancel();
          service.stopSelf();
        },
        cancelOnError: false,
      );
}
