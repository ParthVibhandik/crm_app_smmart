import 'package:flutex_admin/common/components/card/glass_card.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/attendance/controller/attendance_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceHistoryController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(LocalStrings.attendanceHistory.tr, style: regularLarge.copyWith(color: Colors.white)),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorResources.gradientStart,
                  ColorResources.gradientMid,
                  ColorResources.gradientEnd,
                ],
              ),
            ),
            child: controller.isLoading
                ? const CustomLoader()
                : controller.history.isEmpty
                    ? Center(child: Text('No history found', style: regularDefault.copyWith(color: Colors.white70)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 100, left: 15, right: 15, bottom: 20),
                        itemCount: controller.history.length,
                        itemBuilder: (context, index) {
                          final item = controller.history[index];
                          final punchIn = item.punchInTime != null ? DateTime.parse(item.punchInTime!) : null;
                          final punchOut = item.punchOutTime != null ? DateTime.parse(item.punchOutTime!) : null;
                          
                          String duration = '--';
                          if (punchIn != null && punchOut != null) {
                            final diff = punchOut.difference(punchIn);
                            duration = '${diff.inHours}h ${diff.inMinutes % 60}m';
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
                                    Text(
                                      punchIn != null ? DateFormat('EEEE, MMM d').format(punchIn) : 'Unknown Date',
                                      style: semiBoldDefault.copyWith(color: Colors.white),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        duration,
                                        style: regularSmall.copyWith(color: Colors.greenAccent),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white12, height: 25),
                                Row(
                                  children: [
                                    _buildTimeColumn(Icons.login, LocalStrings.checkIn.tr, punchIn != null ? DateFormat('hh:mm a').format(punchIn) : '--'),
                                    const Spacer(),
                                    _buildTimeColumn(Icons.logout, LocalStrings.checkOut.tr, punchOut != null ? DateFormat('hh:mm a').format(punchOut) : '--'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(IconData icon, String label, String time) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: regularExtraSmall.copyWith(color: Colors.white60)),
            Text(time, style: mediumDefault.copyWith(color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
