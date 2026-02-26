import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/lead/model/reminders_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/route/route.dart';
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
        leadRepo: LeadRepo(apiClient: apiClient),
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
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
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
                    ),
                    const Divider(),
                    if (controller.allReminders.isEmpty &&
                        !controller.isLoading)
                      // Optional: Warning/Info if reminders are still loading or empty
                      // Not showing anything to keep UI clean, but debugging helps.
                      const SizedBox.shrink(),
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
        } else if (event is Reminder) {
          return _ReminderTile(reminder: event);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  String _getPriorityLabel(String? priority) {
    switch (priority) {
      case '1':
        return 'Low';
      case '2':
        return 'Medium';
      case '3':
        return 'High';
      case '4':
        return 'Urgent';
      default:
        return 'Unknown';
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.orange;
      case '3':
        return Colors.deepOrange;
      case '4':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.task_alt, color: Colors.blue),
        title: Text(task.name ?? 'Untitled Task'),
        subtitle: Row(
          children: [
            Text('Priority: '),
            Text(
              _getPriorityLabel(task.priority),
              style: TextStyle(
                color: _getPriorityColor(task.priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Text(task.startDate ?? ''),
        onTap: () {
          if (task.id != null) {
            Get.toNamed(RouteHelper.taskDetailsScreen, arguments: task.id);
          }
        },
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
        subtitle: Text(status.punchedIn
            ? '${LocalStrings.checkIn.tr}: ${status.punchInTime ?? '--'}'
            : LocalStrings.notCheckedIn.tr),
        trailing: Text(status.punchedOut ? 'Closed' : 'Active'),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.red.withOpacity(0.3),
      child: ListTile(
        leading: const Icon(Icons.notifications_active, color: Colors.red),
        title: Text(reminder.description ?? 'Untitled Reminder',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Staff: ${reminder.staffId ?? 'Unknown'}'),
        trailing: Text(reminder.date ?? '',
            style: const TextStyle(color: Colors.red)),
        onTap: () {
          // Navigate to lead details screen using relId (lead ID)
          if (reminder.relId != null && reminder.relId!.isNotEmpty) {
            Get.toNamed(RouteHelper.leadDetailsScreen,
                arguments: reminder.relId);
          }
        },
      ),
    );
  }
}
