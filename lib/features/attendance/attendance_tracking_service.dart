import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';

const String BASE_URL = 'https://smmartcrm.in';
const String TRACK_API = '/flutex_admin_api/attendance/track';
const String IS_TRACKING_KEY = 'is_tracking_active';
const String LAST_ALIVE_KEY = 'last_alive_time';
const String PENDING_INTERRUPTION_KEY = 'pending_interruption';

const MethodChannel _locationChannel = MethodChannel(
  'com.dhavalmodi.crm/location_service',
);

StreamSubscription<Position>? _positionSub;
DateTime? _lastSentAt;

/// ==============================
/// HEARTBEAT
/// ==============================
Future<void> _updateLastAlive() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAST_ALIVE_KEY, DateTime.now().toIso8601String());
}

/// ==============================
/// iOS PERSISTENT LOCATION
/// ==============================
Future<void> _toggleIOSPersistentTracking(bool enabled) async {
  if (!Platform.isIOS) return;

  try {
    await _locationChannel.invokeMethod(
      enabled
          ? 'enableSignificantLocationMonitoring'
          : 'disableSignificantLocationMonitoring',
    );
    print('[Tracking] IOS Persistent tracking toggled: $enabled');
  } on PlatformException catch (e) {
    if (e.code == 'MissingPluginException' ||
        e.message?.contains('No implementation found') == true) {
      print(
        '[Tracking] Note: Custom channel not available in background isolate (expected)',
      );
    } else {
      print('[Tracking] IOS PlatformException: $e');
    }
  } catch (e) {
    print('[Tracking] Error toggling persistent tracking: $e');
  }
}

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

  final prefs = await SharedPreferences.getInstance();
  final isTracking = prefs.getBool(IS_TRACKING_KEY) ?? false;
  if (isTracking) {
    print('[Tracking] Persistence detected → Auto-starting service');
    service.startService();
  }
}

/// ==============================
/// iOS BACKGROUND ENTRY
/// ==============================
@pragma('vm:entry-point')
Future<bool> trackingServiceStartIOS(ServiceInstance service) async {
  print('[iOS] 🌙 Background entry triggered');
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

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(IS_TRACKING_KEY, true);

  await _toggleIOSPersistentTracking(true);
  await _updateLastAlive(); // initial heartbeat

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: 'Attendance Tracking',
      content: 'Tracking active',
    );

    _startLocationTracking(
      service: service,
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
      platform: 'ANDROID',
    );
  } else {
    _startLocationTracking(
      service: service,
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
      platform: 'IOS',
    );
  }

  service.on('stop').listen((_) async {
    print('[Tracking] Stop signal received');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_TRACKING_KEY, false);
    await _toggleIOSPersistentTracking(false);
    await _positionSub?.cancel();
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
    await prefs.setBool(IS_TRACKING_KEY, false);
    await _toggleIOSPersistentTracking(false);
    service.stopSelf();
    return;
  }

  if (!await _ensureLocationPermission(platform)) {
    await prefs.setBool(IS_TRACKING_KEY, false);
    await _toggleIOSPersistentTracking(false);
    service.stopSelf();
    return;
  }

  late final LocationSettings locationSettings;
  if (platform == 'IOS') {
    locationSettings = AppleSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
      allowBackgroundLocationUpdates: true,
      activityType: ActivityType.other,
    );
  } else {
    locationSettings = AndroidSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 5),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: 'Attendance Tracking active',
        notificationTitle: 'Attendance Tracking',
        enableWakeLock: true,
      ),
    );
  }

  final dio = Dio();
  final battery = Battery();

  _positionSub?.cancel();
  _positionSub =
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (position) async {
          await _updateLastAlive();

          print(
            '[$platform] Location update: '
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}',
          );

          final prefs = await SharedPreferences.getInstance();
          final currentAttendanceId = prefs.getString('attendance_id');
          final currentToken = prefs.getString('token');
          final interruption = prefs.getString(PENDING_INTERRUPTION_KEY);

          if (currentAttendanceId == null || currentToken == null) {
            print('[$platform] Punch-out detected → stopping tracking');
            await prefs.setBool(IS_TRACKING_KEY, false);
            await _toggleIOSPersistentTracking(false);
            await _positionSub?.cancel();
            service.stopSelf();
            return;
          }

          if (_lastSentAt != null &&
              DateTime.now().difference(_lastSentAt!).inSeconds < 15) {
            return;
          }

          _lastSentAt = DateTime.now();

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
                'interruption': interruption, // ✅ null or string
              },
              options: Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: {
                  'Authorization': 'Bearer $currentToken',
                  'Accept': 'application/json',
                },
              ),
            );

            if (interruption != null) {
              await prefs.remove(PENDING_INTERRUPTION_KEY); // send once
            }

            print('[$platform] ✅ Tracking sent successfully');
          } catch (e) {
            print('[$platform] ❌ Tracking error: $e');
          }
        },
        onError: (error) async {
          print('[$platform] ❌ Location stream error: $error');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(IS_TRACKING_KEY, false);
          await _toggleIOSPersistentTracking(false);
          await _positionSub?.cancel();
          service.stopSelf();
        },
        cancelOnError: false,
      );
}
