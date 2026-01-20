import 'dart:async';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_stats_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardRepo dashboardRepo;
  DashboardController({required this.dashboardRepo});

  bool isLoading = true;
  bool logoutLoading = false;
  int currentPageIndex = 0;
  DashboardModel homeModel = DashboardModel();
  DashboardNewStats newStats = DashboardNewStats.empty();

  // Calendar State
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  bool isAttendanceLoading = false;

  String? punchInTime;
  String? punchOutTime;
  List<CalendarAppointment> selectedDayAppointments = [];

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay, selected)) {
      selectedDay = selected;
      focusedDay = focused;
      update();
      getAttendanceLog(selected);
    }
  }

  Future<void> getAttendanceLog(DateTime date) async {
    isAttendanceLoading = true;
    punchInTime = null;
    punchOutTime = null;
    update();

    // Format date as yyyy-MM-dd (e.g., 2026-01-11)
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    ResponseModel responseModel =
        await dashboardRepo.getAttendanceDate(formattedDate);

    if (responseModel.status) {
      try {
        Map<String, dynamic> responseData =
            jsonDecode(responseModel.responseJson);
        // Assuming the backend returns keys "punch_in" and "punch_out" directly or inside a data object.
        // Based on "backend responds with {punch_in , punch_out}", I'll assume root level or simple structure.
        // Safe access
        if (responseData.containsKey('punch_in')) {
          punchInTime = responseData['punch_in'];
        }
        if (responseData.containsKey('punch_out')) {
          punchOutTime = responseData['punch_out'];
        }
      } catch (e) {
        print("Error parsing attendance date: $e");
      }
    } else {
      // Optional: Show error or just show empty
      // CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isAttendanceLoading = false;
    // Mock appointments for the selected date
    selectedDayAppointments = [
      CalendarAppointment(time: '10:00 AM', title: 'Meeting', client: 'Client A'),
      CalendarAppointment(time: '02:30 PM', title: 'Site Visit', client: 'Client B'),
    ];
    update();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadData();
    isLoading = false;
    update();
  }

  Future<dynamic> loadData() async {
    ResponseModel responseModel = await dashboardRepo.getData();
    if (responseModel.status) {
      homeModel = DashboardModel.fromJson(
        jsonDecode(responseModel.responseJson),
      );
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    _generateMockData();
    update();
  }

  void _generateMockData() {
    newStats = DashboardNewStats(
      leadsTasks: LeadsTasksSummary(
          todayLeads: 5, pendingLeads: 12, todayTasks: 3, pendingTasks: 8),
      leadJourney: [
        LeadJourneyStep(step: 1, label: 'Hot Lead', count: 10),
        LeadJourneyStep(step: 2, label: 'Warm Lead', count: 5),
        LeadJourneyStep(step: 3, label: 'Not Interested', count: 3),
        LeadJourneyStep(step: 4, label: 'Not Reachable', count: 2),
        LeadJourneyStep(step: 5, label: 'Follow Up', count: 1),
      ],
      goals: [
        GoalTarget(period: 'Today', target: 5000, achieved: 1200),
        GoalTarget(period: 'Month', target: 150000, achieved: 85000),
        GoalTarget(period: 'Year', target: 2000000, achieved: 450000),
      ],
      leadStatusPie: {
        'Hot Lead': 10,
        'Warm Lead': 5,
        'Not Interested': 3,
        'Not Reachable': 2,
        'Follow Up': 1,
      },
    );
  }

  // Goals Card State
  String selectedGoalMainTab = 'my'; // 'my' or staff_id
  String selectedGoalSubTab = 'assigned';
  String selectedGoalDateFilter = 'all'; // 'all', 'mtd', 'ytd', 'custom'

  void changeGoalMainTab(String tab) {
    selectedGoalMainTab = tab;
    // Reset sub-tab based on main tab selection logic
    if (tab == 'my') {
      selectedGoalSubTab = 'assigned';
    } else {
      // Logic for subordinate tabs if any
      selectedGoalSubTab = 'subordinate_goals'; 
    }
    update();
  }

  void changeGoalSubTab(String tab) {
    selectedGoalSubTab = tab;
    update();
  }
  
  void changeGoalDateFilter(String filter) {
    selectedGoalDateFilter = filter;
    update();
  }

  Future<void> logout() async {
    logoutLoading = true;
    update();

    ResponseModel responseModel = await dashboardRepo.logout();

    if (responseModel.status) {
      await dashboardRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.accessTokenKey,
        '',
      );
      await dashboardRepo.apiClient.sharedPreferences.setBool(
        SharedPreferenceHelper.rememberMeKey,
        false,
      );
      // Clear attendance tracking prefs on logout to avoid stale background tracking
      await dashboardRepo.apiClient.sharedPreferences.remove('attendance_id');
      await dashboardRepo.apiClient.sharedPreferences.remove('token');
      CustomSnackBar.success(successList: [responseModel.message.tr]);
      Get.offAllNamed(RouteHelper.loginScreen);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    logoutLoading = false;
    update();
  }
}
