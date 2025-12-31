import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import '../controller/calendar_controller.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies if not already done
    if (!Get.isRegistered<CalendarController>()) {
      final apiClient = Get.find<ApiClient>();
      final token = apiClient.sharedPreferences.getString('access_token') ?? '';
      Get.put(CalendarController(
        taskRepo: TaskRepo(apiClient: apiClient),
        attendanceService: AttendanceService(token),
      ));
    }

    return GetBuilder<CalendarController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(LocalStrings.calendar.tr),
            centerTitle: true,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: controller.focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(controller.selectedDay, day),
                      onDaySelected: controller.onDaySelected,
                      eventLoader: controller.getEventsForDay,
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: _buildEventList(controller),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEventList(CalendarController controller) {
    final events = controller.getEventsForDay(controller.selectedDay);

    if (events.isEmpty) {
      return Center(
        child: Text(LocalStrings.noEventsFound.tr),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        if (event is Task) {
          return _TaskTile(task: event);
        } else if (event is AttendanceStatus) {
          return _AttendanceTile(status: event);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.task_alt, color: Colors.blue),
        title: Text(task.name ?? 'Untitled Task'),
        subtitle: Text('Status: ${task.status ?? 'Unknown'}'),
        trailing: Text(task.startDate ?? ''),
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final AttendanceStatus status;
  const _AttendanceTile({required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.fingerprint, color: Colors.green),
        title: Text(LocalStrings.attendance.tr),
        subtitle: Text(
          status.punchedIn 
            ? '${LocalStrings.checkIn.tr}: ${status.punchInTime ?? '--'}'
            : LocalStrings.notCheckedIn.tr
        ),
        trailing: Text(status.punchedOut ? 'Closed' : 'Active'),
      ),
    );
  }
}
