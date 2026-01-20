import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';

class CalendarScheduleCard extends StatelessWidget {
  const CalendarScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.cardRadius)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Calendar', style: regularLarge.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: controller.focusedDay,
                  currentDay: DateTime.now(),
                  selectedDayPredicate: (day) => isSameDay(controller.selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  availableGestures: AvailableGestures.horizontalSwipe,
                  onDaySelected: controller.onDaySelected,
                  onPageChanged: (focusedDay) {
                    controller.focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                 if (controller.selectedDay != null || controller.isAttendanceLoading) ...[
                   const CustomDivider(),
                   const SizedBox(height: 10),
                   if (controller.isAttendanceLoading)
                     const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator())
                     )
                   else
                     Column(
                       children: [
                         Text(
                           DateFormat('MMMM d, y').format(controller.selectedDay!),
                           style: boldLarge,
                         ),
                         const SizedBox(height: 15),
                         // Attendance
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                             _buildPunchInfo('Punch In', controller.punchInTime, Colors.green),
                             Container(height: 30, width: 1, color: Colors.grey[300]),
                             _buildPunchInfo('Punch Out', controller.punchOutTime, Colors.red),
                           ],
                         ),
                         const SizedBox(height: 15),
                         const CustomDivider(),
                         // Appointments
                         Padding(
                           padding: const EdgeInsets.fromLTRB(8, 15, 8, 5),
                           child: Align(alignment: Alignment.centerLeft, child: Text("Appointments", style: regularDefault.copyWith(fontWeight: FontWeight.bold))),
                         ),
                         if(controller.selectedDayAppointments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("No appointments", style: regularSmall.copyWith(color: Colors.grey)),
                            )
                         else
                           ...controller.selectedDayAppointments.map((apt) => ListTile(
                             leading: Icon(Icons.access_time, size: 20, color: Theme.of(context).primaryColor),
                             title: Text(apt.title, style: regularDefault),
                             subtitle: Text('${apt.time} - ${apt.client}'),
                             contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                             dense: true,
                           ))
                       ],
                     ),
                 ] else 
                   Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('Select a date to view details', style: regularSmall.copyWith(color: ColorResources.blueGreyColor)),
                   )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPunchInfo(String label, String? time, Color color) {
    return Column(
      children: [
        Text(label, style: regularDefault.copyWith(color: ColorResources.blueGreyColor)),
        const SizedBox(height: 5),
        Text(time ?? '--:--', style: boldExtraLarge.copyWith(color: color)),
      ],
    );
  }
}
