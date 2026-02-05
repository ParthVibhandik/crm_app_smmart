# Attendance Regularization Feature

## Overview
This feature allows users to view pending attendances (where they punched in but forgot to punch out) and submit regularization requests with a punch-out time and reason.

## API Endpoints Used

1. **GET** `/flutex_admin_api/attendance/get_all_pending_attendances`
   - Fetches all pending attendance records (punched in but not out)
   - Returns list of attendances

2. **POST** `/flutex_admin_api/attendance/regularize`
   - Submits regularization request
   - Parameters:
     - `attendance_id`: ID of the attendance record
     - `punched_out_time`: Time in HH:MM:SS format
     - `reason`: Text reason for regularization

## Files Created

### 1. Model
- **lib/features/attendance/pending_attendance.dart** - Model for pending attendance data

### 2. Service
- **lib/features/attendance/attendance_service.dart** - Added two new methods:
  - `getPendingAttendances()` - Fetches all pending attendances
  - `regularizeAttendance()` - Submits regularization request

### 3. Controller
- **lib/features/attendance/controller/regularization_controller.dart** - Manages state and handles business logic
- **lib/features/attendance/controller/regularization_binding.dart** - Dependency injection

### 4. View (UI)
- **lib/features/attendance/view/regularization_screen.dart** - Main screen with:
  - Beautiful gradient background
  - List of pending attendances
  - Card-based UI with glass morphism effect
  - Regularization dialog with time picker and reason input
  - Pull-to-refresh functionality
  - Loading and empty states

### 5. Navigation
- Added route in **lib/core/route/route.dart**
- Added menu item in Settings screen (**lib/features/menu/view/menu_screen.dart**)

## Features Implemented

✅ **API Integration:**
- GET endpoint for fetching pending attendances
- POST endpoint for submitting regularization requests with validation

✅ **UI Components:**
- List view of pending attendances
- Glass card design matching app style
- Time picker for selecting punch out time
- Reason text input field
- Pull-to-refresh functionality
- Loading states and error handling

✅ **Sidebar Navigation:**
- Added "Regularize Attendance" menu item in Settings screen
- Proper routing with binding for dependency injection

✅ **Features:**
- Fetches pending attendances from API
- Shows attendance cards with date, punch-in time, and status
- Dialog for regularizing attendance
- Form validation (HH:MM:SS format for time)
- Success/error notifications
- Auto-refresh after successful submission
- Empty states with proper messaging

## How to Use

1. Open the app and navigate to **Settings** (menu icon)
2. Tap on **"Regularize Attendance"**
3. View list of pending attendances (where you forgot to punch out)
4. Tap **"Regularize"** button on any pending attendance
5. Select punch-out time using time picker
6. Enter reason for regularization
7. Tap **"Submit"** to send the request

## Technical Details

- **State Management**: GetX
- **HTTP Client**: Dio
- **Form Validation**: Required fields validation + time format (HH:MM:SS)
- **UI Pattern**: Glass morphism cards with gradient background
- **Error Handling**: Snackbar notifications for success/error states
