# Sales Tracker - Active Trip Implementation Summary

## Overview
Implemented feature to handle active trips when user opens sales_tracker_screen. The system now:
1. Checks for active trips from the API when screen loads
2. Shows a dialog if an active trip exists
3. Allows user to continue the trip or end it
4. Stores trip ID securely when trip starts

## Changes Made

### 1. **URL Container** - `lib/core/utils/url_container.dart`
Added new API endpoint:
```dart
static const String salesTrackerGetActiveTripUrl = 'sales-tracker/get-active-trip';
```

### 2. **Trip Session Service** - `lib/features/sales_tracker/model/trip_session.dart` (NEW)
Created secure persistent storage service for trip data:
- `setActiveTrip(tripId, tripData)` - Store active trip ID and data
- `getActiveTripId()` - Retrieve stored trip ID
- `getActiveTripData()` - Retrieve stored trip data
- `hasActiveTrip()` - Check if trip is active
- `clearActiveTrip()` - Clear when trip ends

Uses SharedPreferences for persistent storage with keys:
- `active_trip_id` - Stores the trip ID
- `active_trip_data` - Stores complete trip data

### 3. **Sales Tracker Repository** - `lib/features/sales_tracker/repo/sales_tracker_repo.dart`
Added new API method:
```dart
Future<ResponseModel> getActiveTrip() async {
  // Calls GET /sales-tracker/get-active-trip endpoint
  // Returns ResponseModel with trip data if active trip exists
}
```

### 4. **Sales Tracker Controller** - `lib/features/sales_tracker/controller/sales_tracker_controller.dart`
#### Added imports:
- `trip_session.dart` for persistent storage

#### Added methods:
- `checkAndShowActiveTrip()` - Calls API to check for active trip
- `_showActiveTripDialog()` - Displays dialog with two options:
  - **"Yes, Continue"** - Stores trip ID and continues
  - **"End Trip"** - Closes dialog (implementation pending)

#### Modified:
- `checkAttendanceStatus()` - Now calls `checkAndShowActiveTrip()` after loading leads

### 5. **Continue Trip Screen** - `lib/features/sales_tracker/view/continue_trip_screen.dart`
#### Added imports:
- `trip_session.dart` for storing trip data
- `dart:convert` for JSON encoding

#### Modified `_startTrip()` method:
- Now extracts trip ID from API response
- Stores trip ID using `TripSession.setActiveTrip()`
- Persists trip data for future use

#### Added UI:
- New **"End Trip"** button (red outlined button)
- Positioned below "Start Trip" button
- Includes placeholder method `_endTrip()` for future implementation

## API Response Format
The get-active-trip endpoint returns:
```json
{
  "status": true,
  "data": {
    "id": "trip_id",
    // ... other trip data
  }
}
```

or if no active trip:
```json
{
  "status": false,
  "message": "No active trip found"
}
```

## Flow Diagram
```
SalesTrackerScreen Opens
    ↓
checkAttendanceStatus() executes
    ↓
If punched in: Call checkAndShowActiveTrip()
    ↓
getActiveTrip() API call
    ↓
If status == true:
    Show Dialog with "Yes, Continue" and "End Trip"
    ↓
    If "Yes, Continue":
        Store trip ID in TripSession
        Show success message
    ↓
User starts/continues trip on ContinueTripScreen
    ↓
_startTrip() called
    ↓
Extract trip ID from response
    ↓
Store in TripSession using setActiveTrip()
    ↓
Trip ID available for future API calls
```

## Storage Details
- **Type**: SharedPreferences (persistent across app sessions)
- **Security**: Stored securely on device
- **Persistence**: Data survives app restart
- **Keys Used**:
  - `active_trip_id` - The unique trip identifier
  - `active_trip_data` - Complete trip JSON data

## Pending Implementation
The "End Trip" button is currently a placeholder with a TODO comment. Implementation will:
1. Call end-trip API endpoint
2. Clear trip ID from TripSession
3. Reset UI accordingly
