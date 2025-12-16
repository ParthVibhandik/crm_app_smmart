import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:dio/dio.dart';

const String fetchBackgroundLocationTask = "fetchBackgroundLocation";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackgroundLocationTask:
        try {
          // Check/Request permissions might fail in background if not already granted.
          // We assume permissions are granted during the app usage (punch-in).
          
          final Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
          
          final Battery battery = Battery();
          final int batteryLevel = await battery.batteryLevel;

          // Send to backend
          // Note: We need a new Dio instance here as this runs in a separate isolate
          final dio = Dio(BaseOptions(baseUrl: 'https://smmartcrm.in'));
          
          // data format based on user requirement "tracking location and battery"
          // Assuming an endpoint exists or using a generic log endpoint.
          // Since the user didn't specify the EXACT endpoint for tracking, 
          // I will use a placeholder or the same punch-in endpoint if appropriate, 
          // but valid tracking usually goes to a specific route.
          // I'll assume '/flutex_admin_api/tracking' or similar. 
          // IF NOT EXIST, I might stick to just logging or try to infer.
          // Looking at existing code, base URL is flutex_admin_api.
          // I will try to post to '/flutex_admin_api/attendance/track' 
          // or just print for now if unsure, but user said "start tracking".
          // I'll create a best-guess implementation and comment it.
          
          // actually, re-reading the user prompt: "send the image and punch in time to backend" (for punch in).
          // "start tracking location and battery... every 15 mins".
          
          // I will define the tracking function using a generic POST for now.
          // We might need the auth token. InputData can carry the token.
          final String? token = inputData?['token'];
          
          if (token != null) {
             dio.options.headers['Authorization'] = 'Bearer $token';
             await dio.post('/flutex_admin_api/attendance/track', data: {
               'latitude': position.latitude,
               'longitude': position.longitude,
               'battery_level': batteryLevel,
               'timestamp': DateTime.now().toIso8601String(),
             });
          }
          
        } catch (e) {
           return Future.value(false);
        }
        break;
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static void startTracking(String token) {
    Workmanager().registerPeriodicTask(
      "1",
      fetchBackgroundLocationTask,
      frequency: const Duration(minutes: 15),
      inputData: {'token': token},
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
  
  static void stopTracking() {
    Workmanager().cancelAll();
  }
}
