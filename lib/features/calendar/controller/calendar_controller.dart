import 'dart:convert';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/lead/model/reminders_model.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  final TaskRepo taskRepo;
  final AttendanceService attendanceService;
  final LeadRepo leadRepo;

  CalendarController({
    required this.taskRepo,
    required this.attendanceService,
    required this.leadRepo,
  });

  bool isLoading = true;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  List<Task> allTasks = [];
  List<Reminder> allReminders = [];
  AttendanceStatus? todayAttendance;
  Map<String, AttendanceStatus> attendanceCache = {};

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    update();

    await Future.wait([
      _loadAllTasks(),
      _loadTodayAttendance(),
      _loadAllLeadReminders(),
    ]);

    isLoading = false;
    update();
  }

  Future<void> _loadAllTasks() async {
    try {
      // print('CalendarController: Loading tasks...');
      ResponseModel responseModel = await taskRepo.getAllTasks(page: 0);
      // print('CalendarController: Task response status: ${responseModel.status}');

      // LOG RAW JSON
      // print('CalendarController: Task RAW JSON: ${responseModel.responseJson}');

      if (responseModel.status) {
        final tasksModel =
            TasksModel.fromJson(jsonDecode(responseModel.responseJson));
        allTasks = tasksModel.data ?? [];
        // print('CalendarController: Loaded ${allTasks.length} tasks.');
        if (allTasks.isNotEmpty) {
          // print('CalendarController: Sample Task Date: ${allTasks.first.startDate}');
        }
      }
    } catch (e) {
      // print('Error loading tasks for calendar: $e');
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      todayAttendance = await attendanceService.getTodayStatus();
    } catch (e) {
      // print('Error loading attendance for calendar: $e');
    }
  }

  Future<void> _loadAllLeadReminders() async {
    try {
      // print('CalendarController: Loading leads for reminders...');
      ResponseModel leadsResponse = await leadRepo.getAllLeads();
      // print('CalendarController: Leads response status: ${leadsResponse.status}');

      // LOG RAW JSON
      // print('CalendarController: Leads RAW JSON: ${leadsResponse.responseJson}');

      if (leadsResponse.status) {
        var decoded = jsonDecode(leadsResponse.responseJson);
        List<dynamic> leadsList = [];
        if (decoded is Map && decoded.containsKey('data')) {
          if (decoded['data'] is List) {
            leadsList = decoded['data'];
          } else if (decoded['data'] is Map &&
              decoded['data'].containsKey('leads')) {
            leadsList = decoded['data']['leads']; // Handle pagination structure
          }
        } else if (decoded is List) {
          leadsList = decoded;
        }

        // print('CalendarController: Found ${leadsList.length} leads (checking first 20).');

        List<Future<void>> futures = [];
        for (var item in leadsList.take(20)) {
          if (item is Map) {
            String leadId = '';
            if (item.containsKey('id')) leadId = item['id'].toString();

            if (leadId.isNotEmpty) {
              futures.add(_fetchRemindersForLead(leadId));
            }
          }
        }
        await Future.wait(futures);
        // print('CalendarController: Loaded total ${allReminders.length} reminders.');
        if (allReminders.isNotEmpty) {
          // print('CalendarController: Sample Reminder Date: ${allReminders.first.date}');
        }
      }
    } catch (e) {
      // print('Error loading reminders: $e');
    }
  }

  Future<void> _fetchRemindersForLead(String leadId) async {
    try {
      ResponseModel response = await leadRepo.getLeadReminders(leadId);
      if (response.status) {
        final model =
            RemindersModel.fromJson(jsonDecode(response.responseJson));
        if (model.data != null) {
          allReminders.addAll(model.data!);
        }
      }
    } catch (_) {}
  }

  List<dynamic> getEventsForDay(DateTime day) {
    List<dynamic> events = [];

    // Tasks
    events.addAll(allTasks.where((task) {
      if (task.startDate == null) return false;
      try {
        // Tries standard parse first
        DateTime startDate = DateTime.parse(task.startDate!);
        return isSameDay(startDate, day);
      } catch (_) {
        // print('CalendarController: Failed to parse task date: ${task.startDate}');
        return false;
      }
    }));

    // Reminders
    events.addAll(allReminders.where((reminder) {
      if (reminder.date == null) return false;
      try {
        DateTime reminderDate = DateTime.parse(reminder.date!);
        return isSameDay(reminderDate, day);
      } catch (_) {
        // Debug failed parse
        // print('CalendarController: Failed to parse reminder date: ${reminder.date}');
        return false;
      }
    }));

    // Attendance
    String dateKey = day.toString().split(' ')[0];
    if (attendanceCache.containsKey(dateKey)) {
      events.add(attendanceCache[dateKey]);
    } else if (isSameDay(day, DateTime.now()) && todayAttendance != null) {
      events.add(todayAttendance);
    }

    return events;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay = selected;
    focusedDay = focused;
    _fetchAttendanceForDate(selected);
    update();
  }

  Future<void> _fetchAttendanceForDate(DateTime date) async {
    String dateKey = date.toString().split(' ')[0];
    if (attendanceCache.containsKey(dateKey)) return;

    if (isSameDay(date, DateTime.now()) && todayAttendance != null) {
      attendanceCache[dateKey] = todayAttendance!;
      update();
      return;
    }

    AttendanceStatus? status =
        await attendanceService.getAttendanceForDate(date);

    // Always store a status. If API returns null, assume Absent/No Data.
    attendanceCache[dateKey] = status ??
        AttendanceStatus(
          punchedIn: false,
          punchedOut: false,
          statusLabel: 'Absent',
          punchInTime: '--',
          punchOutTime: '--',
        );
    update();
  }
}
