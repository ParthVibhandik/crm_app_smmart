import 'package:flutex_admin/common/components/card/glass_card.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/attendance/controller/regularization_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RegularizationScreen extends StatelessWidget {
  const RegularizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegularizationController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Regularize Attendance',
              style: regularLarge.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorResources.primaryColor,
                  ColorResources.primaryColor.withValues(alpha: 0.8),
                  ColorResources.darkColor,
                ],
              ),
            ),
            child: controller.isLoading
                ? const CustomLoader()
                : controller.pendingAttendances.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No pending attendances',
                              style: regularLarge.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: controller.fetchPendingAttendances,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 100,
                            left: 15,
                            right: 15,
                            bottom: 20,
                          ),
                          itemCount: controller.pendingAttendances.length,
                          itemBuilder: (context, index) {
                            final attendance =
                                controller.pendingAttendances[index];
                            return _buildAttendanceCard(
                              context,
                              attendance,
                              controller,
                            );
                          },
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard(
    BuildContext context,
    attendance,
    RegularizationController controller,
  ) {
    DateTime? punchInDateTime;
    if (attendance.punchIn != null) {
      try {
        punchInDateTime = DateTime.parse(attendance.punchIn!);
      } catch (e) {
        // If parsing fails, keep null
      }
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.attendanceDate ?? 'Unknown Date',
                      style: semiBoldDefault.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pending',
                  style: regularSmall.copyWith(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 25),
          Row(
            children: [
              Icon(
                Icons.login,
                color: Colors.greenAccent.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Punch In: ',
                style: regularDefault.copyWith(color: Colors.white60),
              ),
              Text(
                punchInDateTime != null
                    ? DateFormat('hh:mm a').format(punchInDateTime)
                    : '--',
                style: semiBoldDefault.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showRegularizationDialog(
                context,
                attendance,
                controller,
              ),
              icon: const Icon(Icons.edit_note, size: 20),
              label: const Text('Regularize'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorResources.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegularizationDialog(
    BuildContext context,
    attendance,
    RegularizationController controller,
  ) {
    final timeController = TextEditingController();
    final reasonController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Regularize Attendance',
          style: semiBoldLarge.copyWith(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${attendance.attendanceDate ?? "Unknown"}',
                style: regularDefault.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                'Punch Out Time',
                style: regularDefault.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: timeController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select time',
                  hintStyle: const TextStyle(color: Colors.white38),
                  suffixIcon:
                      const Icon(Icons.access_time, color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onTap: () async {
                  final time = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    selectedTime = time;
                    timeController.text = time.format(dialogContext);
                  }
                },
              ),
              const SizedBox(height: 15),
              Text(
                'Reason',
                style: regularDefault.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason for regularization',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: regularDefault.copyWith(color: Colors.white60),
            ),
          ),
          GetBuilder<RegularizationController>(
            builder: (ctrl) => ElevatedButton(
              onPressed: ctrl.isSubmitting
                  ? null
                  : () async {
                      if (selectedTime == null) {
                        Get.snackbar(
                          'Error',
                          'Please select punch out time',
                          backgroundColor: Colors.red.withValues(alpha: 0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      if (reasonController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please enter a reason',
                          backgroundColor: Colors.red.withValues(alpha: 0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      // Format time as HH:MM:SS
                      final hour =
                          selectedTime!.hour.toString().padLeft(2, '0');
                      final minute =
                          selectedTime!.minute.toString().padLeft(2, '0');
                      final timeString = '$hour:$minute:00';

                      await controller.regularize(
                        attendanceId: attendance.id,
                        punchedOutTime: timeString,
                        reason: reasonController.text.trim(),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorResources.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: ctrl.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
