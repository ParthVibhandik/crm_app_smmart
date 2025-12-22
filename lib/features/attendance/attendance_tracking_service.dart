import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutex_admin/core/service/notification_service.dart';

const String BASE_URL = 'https://smmartcrm.in';
const String TRACK_API = '/flutex_admin_api/attendance/track';
const String GPS_OFF_API = '/flutex_admin_api/attendance/gpsClosed';

const String IS_TRACKING_KEY = 'is_tracking_active';
const String LAST_ALIVE_KEY = 'last_alive_time';
const String PENDING_INTERRUPTION_KEY = 'pending_interruption';
const String GPS_OFF_NOTIFIED_KEY = 'gps_off_notified';

const MethodChannel _locationChannel = MethodChannel(
  'com.dhavalmodi.crm/location_service',
);

StreamSubscription<Position>? _positionSub;
StreamSubscription<ServiceStatus>? _gpsServiceSub;

DateTime? _lastSentAt;
bool _gpsWasOn = true;
bool _iosNotificationsReady = false;
final FlutterLocalNotificationsPlugin _localFln =
    FlutterLocalNotificationsPlugin();

Future<void> _ensureIOSLocalNotifications() async {
  if (_iosNotificationsReady) return;
  try {
    await NotificationService.initialize(_localFln);
    _iosNotificationsReady = true;
  } catch (e) {
    print('[IOS] Local notification init failed: $e');
  }
}

/// ==============================
/// HEARTBEAT
/// ==============================
Future<void> _updateLastAlive() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAST_ALIVE_KEY, DateTime.now().toIso8601String());
}

/// ==============================
/// GPS OFF API (EDGE TRIGGER)
/// ==============================
Future<void> _notifyGpsOff(
  String platform, {
  AndroidServiceInstance? androidService,
}) async {
  final prefs = await SharedPreferences.getInstance();

  final attendanceId = prefs.getString('attendance_id');
  final token = prefs.getString('token');
  final alreadyNotified = prefs.getBool(GPS_OFF_NOTIFIED_KEY) ?? false;

  if (attendanceId == null || token == null || alreadyNotified) return;

  try {
    print('[$platform] ⚠️ gpsClosed → sending for attendance_id=$attendanceId');
    if (androidService != null) {
      androidService.setForegroundNotificationInfo(
        title: 'Attendance Tracking',
        content: 'GPS is turned off, please enable location services.',
      );
    }
    await Dio().post(
      '$BASE_URL$GPS_OFF_API',
      data: {'attendance_id': attendanceId, 'is_gps_closed': '1'},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    await prefs.setBool(GPS_OFF_NOTIFIED_KEY, true);
    print('[$platform] 🚫 GPS OFF → API hit success');

    if (Platform.isIOS) {
      await _ensureIOSLocalNotifications();
      if (_iosNotificationsReady) {
        await NotificationService.showBigTextNotification({
          'title': 'GPS off',
          'body': 'Tracking paused until you re-enable location.',
        }, _localFln);
      }
    }
  } catch (e) {
    print('[$platform] ❌ GPS OFF API failed: $e');
  }
}

/// ==============================
/// GPS SERVICE STATE LISTENER
/// ==============================
Future<void> _startGpsServiceListener(
  String platform,
  ServiceInstance service,
) async {
  await _gpsServiceSub?.cancel();

  _gpsServiceSub = Geolocator.getServiceStatusStream().listen((status) async {
    final prefs = await SharedPreferences.getInstance();
    final isPunchedIn = prefs.getString('attendance_id') != null;

    if (!isPunchedIn) return;

    if (_gpsWasOn && status == ServiceStatus.disabled) {
      _gpsWasOn = false;
      print('[$platform] GPS turned OFF (service status disabled)');
      await _notifyGpsOff(
        platform,
        androidService: service is AndroidServiceInstance ? service : null,
      );
      await _positionSub?.cancel();
      _positionSub = null;
    }

    if (status == ServiceStatus.enabled) {
      _gpsWasOn = true;
      print('[$platform] GPS turned ON (service status enabled)');
      await prefs.setBool(GPS_OFF_NOTIFIED_KEY, false);
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Attendance Tracking',
          content: 'Tracking active',
        );
      }
      _startLocationTracking(
        service: service,
        accuracy: Platform.isIOS
            ? LocationAccuracy.best
            : LocationAccuracy.high,
        distanceFilter: 1,
        platform: platform,
      );
    }
  });
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
  } catch (_) {}
}

Future<bool> _ensureLocationPermission(String platform) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('[$platform] ensurePermission: location service OFF');
    return false;
  }

  var permission = await Geolocator.checkPermission();
  print('[$platform] ensurePermission: current perm=$permission');
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    print('[$platform] ensurePermission: requested perm -> $permission');
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print('[$platform] ensurePermission: denied/forever');
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
      autoStart: true,
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
  if (prefs.getBool(IS_TRACKING_KEY) ?? false) {
    service.startService();
  }
}

/// ==============================
/// iOS BACKGROUND ENTRY
/// ==============================
@pragma('vm:entry-point')
Future<bool> trackingServiceStartIOS(ServiceInstance service) async {
  trackingServiceStart(service);
  return true;
}

/// ==============================
/// SERVICE ENTRY POINT
/// ==============================
@pragma('vm:entry-point')
Future<void> trackingServiceStart(ServiceInstance service) async {
  _lastSentAt = null;
  await _positionSub?.cancel();
  await _gpsServiceSub?.cancel();
  print('[Tracking] Service entry');

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(IS_TRACKING_KEY, true);

  await _toggleIOSPersistentTracking(true);
  await _updateLastAlive();

  final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
  await _startGpsServiceListener(platform, service);

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  _startLocationTracking(
    service: service,
    accuracy: Platform.isIOS ? LocationAccuracy.best : LocationAccuracy.high,
    distanceFilter: 1,
    platform: platform,
  );

  service.on('stop').listen((_) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_TRACKING_KEY, false);
    await _toggleIOSPersistentTracking(false);
    await _positionSub?.cancel();
    await _gpsServiceSub?.cancel();
    service.stopSelf();
  });
}

/// ==============================
/// LOCATION TRACKING
/// ==============================
Future<void> _startLocationTracking({
  required ServiceInstance service,
  required LocationAccuracy accuracy,
  required int distanceFilter,
  required String platform,
}) async {
  await _positionSub?.cancel();
  _positionSub = null;

  final prefs = await SharedPreferences.getInstance();
  final attendanceId = prefs.getString('attendance_id');
  final token = prefs.getString('token');

  if (attendanceId == null || token == null) {
    service.stopSelf();
    return;
  }

  if (!await _ensureLocationPermission(platform)) {
    print(
      '[$platform] startLocationTracking: permission/service missing, waiting',
    );
    return;
  }

  final locationSettings = Platform.isIOS
      ? AppleSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
          allowBackgroundLocationUpdates: true,
          pauseLocationUpdatesAutomatically: false,
        )
      : AndroidSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
          intervalDuration: const Duration(seconds: 5),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Attendance Tracking',
            notificationText: 'Tracking active',
            enableWakeLock: true,
          ),
        );

  final dio = Dio();
  final battery = Battery();

  _positionSub =
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (position) async {
          print(
            '[$platform] position stream -> ${position.latitude},${position.longitude}',
          );
          await _updateLastAlive();

          if (_lastSentAt != null &&
              DateTime.now().difference(_lastSentAt!).inSeconds < 15) {
            return;
          }

          _lastSentAt = DateTime.now();

          try {
            final batteryLevel = await battery.batteryLevel;
            final charging =
                (await battery.batteryState) == BatteryState.charging ? 1 : 0;

            print('[$platform] posting track...');
            await dio.post(
              '$BASE_URL$TRACK_API',
              data: {
                'attendance_id': attendanceId,
                'latitude': position.latitude.toString(),
                'longitude': position.longitude.toString(),
                'battery_percent': batteryLevel.toString(),
                'is_charging': charging.toString(),
              },
              options: Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: {'Authorization': 'Bearer $token'},
              ),
            );
            print('[$platform] ✅ track success');
          } catch (_) {}
        },
        onError: (_) async {
          print('[$platform] position stream error, will retry in 5s');
          await _positionSub?.cancel();
          _positionSub = null;
          // Keep service alive; attempt to restart tracking after a short delay.
          Future.delayed(const Duration(seconds: 5), () {
            _startLocationTracking(
              service: service,
              accuracy: accuracy,
              distanceFilter: distanceFilter,
              platform: platform,
            );
          });
        },
      );
}
