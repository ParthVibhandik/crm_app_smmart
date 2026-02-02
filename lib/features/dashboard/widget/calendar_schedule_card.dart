import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/calendar/controller/calendar_controller.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/lead/model/reminders_model.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart'; // Fixed import
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart'; // Fixed import
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';

class CalendarScheduleCard extends StatelessWidget {
  const CalendarScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure CalendarController is initialized
    if (!Get.isRegistered<CalendarController>()) {
      final apiClient = Get.find<ApiClient>();
      final token = apiClient.sharedPreferences.getString('access_token') ?? '';
      Get.put(CalendarController(
        taskRepo: TaskRepo(apiClient: apiClient),
        attendanceService: AttendanceService(token),
        leadRepo: LeadRepo(apiClient: apiClient),
      ));
    }

    return GetBuilder<CalendarController>(
      builder: (controller) {
        // Fetch events for selected day to display in list
        // Note: controller.selectedDay might be initialized or null
        DateTime displayDate = controller.selectedDay ?? DateTime.now();
        List<dynamic> dayEvents = controller.getEventsForDay(displayDate);

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
                  eventLoader: controller.getEventsForDay,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();
                      // Prioritize Reminder (Red) then Task (Orange)
                      bool hasReminder = events.any((e) => e is Reminder);
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasReminder ? Colors.red : Colors.orange,
                          ),
                          width: 8.0,
                          height: 8.0,
                        ),
                      );
                    },
                  ),
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
                const CustomDivider(),
                const SizedBox(height: 10),
                if (controller.isLoading)
                   const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator())
                   )
                else
                   Column(
                     children: [
                       Text(
                         DateFormat('MMMM d, y').format(displayDate),
                         style: boldLarge,
                       ),
                       const SizedBox(height: 15),
                       // Display List of Events for the Day
                       if (dayEvents.isEmpty)
                         Padding(
                           padding: const EdgeInsets.all(10),
                           child: Text("No events for this day", style: regularSmall.copyWith(color: Colors.grey)),
                         )
                       else ...[
                         // 1. Show Attendance First
                         ...dayEvents.where((e) => e is AttendanceStatus).map((e) {
                            final event = e as AttendanceStatus;
                            return Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
                                 child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                 children: [
                                   _buildPunchInfo('Punch In', event.punchInTime, Colors.green),
                                   Container(height: 30, width: 1, color: Colors.grey[300]),
                                   _buildPunchInfo('Punch Out', event.punchOutTime, Colors.red),
                                 ],
                               ),
                             );
                         }),
                         // 2. Show Other Events (Tasks, Reminders)
                         ...dayEvents.where((e) => e is! AttendanceStatus).map((event) {
                             if (event is Task) {
                               return ListTile(
                                  leading: const Icon(Icons.task_alt, color: Colors.orange),
                                  title: Text(event.name ?? 'Untitled Task', style: mediumSmall),
                                  subtitle: Text('Status: ${event.status ?? 'Unknown'}', style: regularSmall),
                               );
                             } else if (event is Reminder) {
                               return ListTile(
                                  leading: const Icon(Icons.notifications_active, color: Colors.red),
                                  title: Text(event.description ?? 'Untitled Reminder', style: mediumSmall),
                                  subtitle: Text('Staff: ${event.staffId ?? 'Unknown'}', style: regularSmall),
                               );
                             }
                             return const SizedBox.shrink();
                         })
                       ],
                     ],
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
