import 'dart:convert';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  final TaskRepo taskRepo;
  final AttendanceService attendanceService;

  CalendarController({required this.taskRepo, required this.attendanceService});

  bool isLoading = true;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  
  List<Task> allTasks = [];
  AttendanceStatus? todayAttendance;

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
    ]);

    isLoading = false;
    update();
  }

  Future<void> _loadAllTasks() async {
    try {
      // Fetching first page of tasks for now. 
      // In a real app, we might need an API to fetch tasks by date range.
      ResponseModel responseModel = await taskRepo.getAllTasks(page: 0);
      if (responseModel.status) {
        final tasksModel = TasksModel.fromJson(jsonDecode(responseModel.responseJson));
        allTasks = tasksModel.data ?? [];
      }
    } catch (e) {
      print('Error loading tasks for calendar: $e');
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      todayAttendance = await attendanceService.getTodayStatus();
    } catch (e) {
      print('Error loading attendance for calendar: $e');
    }
  }

  List<dynamic> getEventsForDay(DateTime day) {
    List<dynamic> events = [];
    
    // Add tasks that start or are due on this day
    events.addAll(allTasks.where((task) {
      if (task.startDate == null) return false;
      try {
        final startDate = DateTime.parse(task.startDate!);
        return isSameDay(startDate, day);
      } catch (_) {
        return false;
      }
    }));

    // Add attendance if it's today
    if (isSameDay(day, DateTime.now()) && todayAttendance != null) {
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
    update();
  }
}
