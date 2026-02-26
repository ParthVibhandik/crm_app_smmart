import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart';
import 'package:get/get.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceService attendanceService;

  AttendanceHistoryController({required this.attendanceService});

  bool isLoading = true;
  List<AttendanceStatus> history = [];

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading = true;
    update();

    try {
      // For now, if we don't have a real history endpoint, we'll mock some data
      // based on the assumption that a real API would return a list of AttendanceStatus.
      // We will try a hypothetical history endpoint first.

      // If we find the real endpoint later, we update this.
      // For the "Pro" version, we want to at least show the structure.

      // Mock Data for demonstration if real fetch fails or to populate the UI
      await Future.delayed(const Duration(seconds: 1));

      history = [
        AttendanceStatus(
          punchedIn: true,
          punchedOut: true,
          punchInTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 9))
              .toIso8601String(),
          punchOutTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1))
              .toIso8601String(),
        ),
        AttendanceStatus(
          punchedIn: true,
          punchedOut: true,
          punchInTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 8, minutes: 30))
              .toIso8601String(),
          punchOutTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: 0, minutes: 15))
              .toIso8601String(),
        ),
      ];
    } catch (e) {
      print('[AttendanceHistory] Error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }
}
