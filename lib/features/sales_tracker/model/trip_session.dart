import 'package:shared_preferences/shared_preferences.dart';

class TripSession {
  static const _tripIdKey = 'active_trip_id';
  static const _tripDataKey = 'active_trip_data';

  /// Store the active trip ID persistently and securely
  static Future<void> setActiveTrip(String tripId, {String? tripData}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tripIdKey, tripId);
    if (tripData != null) {
      await prefs.setString(_tripDataKey, tripData);
    }
    print('[TripSession] Active trip ID stored: $tripId');
  }

  /// Retrieve the active trip ID
  static Future<String?> getActiveTripId() async {
    final prefs = await SharedPreferences.getInstance();
    final tripId = prefs.getString(_tripIdKey);
    print('[TripSession] Retrieved active trip ID: $tripId');
    return tripId;
  }

  /// Retrieve the active trip data
  static Future<String?> getActiveTripData() async {
    final prefs = await SharedPreferences.getInstance();
    final tripData = prefs.getString(_tripDataKey);
    print('[TripSession] Retrieved active trip data: $tripData');
    return tripData;
  }

  /// Check if there is an active trip
  static Future<bool> hasActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final hasTrip = prefs.containsKey(_tripIdKey);
    print('[TripSession] hasActiveTrip: $hasTrip');
    return hasTrip;
  }

  /// Clear the active trip (when trip ends)
  static Future<void> clearActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripIdKey);
    await prefs.remove(_tripDataKey);
    print('[TripSession] Active trip cleared');
  }
}
