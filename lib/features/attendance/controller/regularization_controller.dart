import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/pending_attendance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegularizationController extends GetxController {
  final AttendanceService attendanceService;

  RegularizationController({required this.attendanceService});

  bool isLoading = true;
  List<PendingAttendance> pendingAttendances = [];
  bool isSubmitting = false;

  @override
  void onInit() {
    super.onInit();
    fetchPendingAttendances();
  }

  Future<void> fetchPendingAttendances() async {
    isLoading = true;
    update();

    try {
      pendingAttendances = await attendanceService.getPendingAttendances();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> regularize({
    required String attendanceId,
    required String punchedOutTime,
    required String reason,
  }) async {
    if (isSubmitting) return;

    isSubmitting = true;
    update();

    try {
      final result = await attendanceService.regularizeAttendance(
        attendanceId: attendanceId,
        punchedOutTime: punchedOutTime,
        reason: reason,
      );

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          result['message'] ?? 'Regularization request submitted',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Refresh the list
        await fetchPendingAttendances();

        // Close dialog if open
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to submit regularization',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSubmitting = false;
      update();
    }
  }
}
