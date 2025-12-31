# Active Trip Feature - Quick Reference

## Feature Overview
When a user opens the Sales Tracker screen, the app will:
1. Check if they have an active trip from the previous session
2. If yes, show a dialog: "You have one active trip. Do you want to continue?"
3. Options: "Yes, Continue" or "End Trip"
4. Store the trip ID securely when starting/continuing a trip

## Files Modified/Created

| File | Type | Changes |
|------|------|---------|
| `lib/core/utils/url_container.dart` | Modified | Added `salesTrackerGetActiveTripUrl` endpoint |
| `lib/features/sales_tracker/model/trip_session.dart` | Created | New secure storage service for trip data |
| `lib/features/sales_tracker/repo/sales_tracker_repo.dart` | Modified | Added `getActiveTrip()` method |
| `lib/features/sales_tracker/controller/sales_tracker_controller.dart` | Modified | Added active trip checking logic |
| `lib/features/sales_tracker/view/continue_trip_screen.dart` | Modified | Added trip ID storage and End Trip button |

## Key Components

### TripSession Service
Located at: `lib/features/sales_tracker/model/trip_session.dart`

**Methods:**
- `setActiveTrip(tripId, {tripData})` - Store trip ID persistently
- `getActiveTripId()` - Retrieve stored trip ID
- `hasActiveTrip()` - Check if trip exists
- `clearActiveTrip()` - Remove trip data

**Storage Keys:**
- `active_trip_id` - Trip identifier
- `active_trip_data` - Complete trip JSON

### API Endpoints

**Get Active Trip:**
- URL: `sales-tracker/get-active-trip`
- Method: POST
- Response: 
  ```json
  {
    "status": true,
    "data": { "id": "trip_id", ... }
  }
  ```

## Usage Example

### Accessing Stored Trip ID
```dart
// Get the stored trip ID
String? tripId = await TripSession.getActiveTripId();

// Check if trip is active
bool hasTrip = await TripSession.hasActiveTrip();

// Get full trip data
String? tripData = await TripSession.getActiveTripData();
```

## Dialog Flow
```
Sales Tracker Screen Opens
        ↓
Check if punched in
        ↓
Load leads & check for active trip
        ↓
API returns active trip
        ↓
Show AlertDialog:
┌─────────────────────────────────┐
│  Active Trip Found              │
│  You have one active trip.      │
│  Do you want to continue?       │
│                                 │
│  [End Trip]  [Yes, Continue]    │
└─────────────────────────────────┘
```

## Implementation Status

✅ **Completed:**
- Active trip checking on screen load
- Dialog showing with user options
- Trip ID persistent storage
- Trip ID extraction from API response
- End Trip button in UI (placeholder functionality)

⏳ **Pending:**
- End Trip API call and logic (marked with TODO)
- Confirmation dialog for ending trip
- Trip data clearing on end

## Testing Checklist

- [ ] API endpoint `sales-tracker/get-active-trip` is working
- [ ] Dialog appears when app has active trip
- [ ] Trip ID is stored correctly in SharedPreferences
- [ ] Trip ID persists after app restart
- [ ] Start Trip button stores new trip ID
- [ ] End Trip button placeholder works
- [ ] All navigation flows correctly

## Notes
- Trip data is stored locally in SharedPreferences
- Storage is persistent and survives app restart
- Trip ID is used for subsequent API calls
- Consider encrypting sensitive trip data for future enhancement
