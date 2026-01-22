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

class DashboardSubordinate {
  final String id;
  final String name;
  final bool hasData; // Whether this subordinate has any goals, leads, or tasks
  DashboardSubordinate(
      {required this.id, required this.name, this.hasData = false});

  @override
  bool operator ==(Object other) =>
      other is DashboardSubordinate && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class DashboardController extends GetxController {
  DashboardRepo dashboardRepo;
  DashboardController({required this.dashboardRepo});

  List<DashboardSubordinate> unifiedSubordinates = [];

  void _extractUnifiedSubordinates() {
    unifiedSubordinates = [];
    Map<String, String> idToName = {};
    Set<String> idsWithData = {}; // Track which IDs have actual data

    // 1. From Goals (subordinatesGoals) - Build ID to Name mapping
    if (homeModel.goals?.subordinatesGoals != null) {
      for (var goal in homeModel.goals!.subordinatesGoals!) {
        if (goal.staffId != null) {
          String name =
              "${goal.staffFirstname ?? ''} ${goal.staffLastname ?? ''}".trim();
          if (name.isEmpty) name = "Staff ${goal.staffId}";
          idToName[goal.staffId!] = name;
          idsWithData.add(goal.staffId!); // Has goals
        }
      }
    }

    // 2. From LeadsTasks - Extract ALL subordinate names (even with empty arrays)
    LeadsTasks? tasks = homeModel.leadsTasks;
    if (tasks != null) {
      // Helper to scan maps and extract IDs from items OR match names with existing IDs
      void scanMap(
          Map<String, List<LeadTaskItem>>? map, bool markAsHavingData) {
        if (map == null) return;
        map.forEach((name, items) {
          // First check if this name already exists in idToName
          bool nameAlreadyExists = false;
          String? existingId;
          for (var entry in idToName.entries) {
            if (entry.value == name) {
              nameAlreadyExists = true;
              existingId = entry.key;
              break;
            }
          }

          // If name already exists, just mark as having data if needed and skip
          if (nameAlreadyExists &&
              items.isNotEmpty &&
              markAsHavingData &&
              existingId != null) {
            idsWithData.add(existingId);
            return; // Skip further processing for this name
          } else if (nameAlreadyExists) {
            return; // Name already processed, skip entirely
          }

          // Try to find an assigned ID from items
          String? foundId;
          if (items.isNotEmpty) {
            for (var item in items) {
              if (item.assigned != null && item.assigned!.isNotEmpty) {
                foundId = item.assigned;
                if (markAsHavingData && foundId != null) {
                  idsWithData.add(foundId); // Has data
                }
                break;
              }
            }
          }

          if (foundId != null) {
            // We found an ID from items
            idToName[foundId] = name;
          } else {
            // No ID found, create a synthetic ID from the name
            // This ensures the subordinate is visible even without an ID
            String syntheticId = name.replaceAll(' ', '_').toLowerCase();
            idToName[syntheticId] = name;
          }
        });
      }

      // Scan all maps
      scanMap(tasks.todaySubords, true);
      scanMap(tasks.pendingSubords, true);

      // 3. From subordinatesTasks
      if (tasks.subordinatesTasks != null) {
        scanMap(tasks.subordinatesTasks, true);
      }
    }

    // Convert to list and sort: those with data first, then those without
    List<DashboardSubordinate> withData = [];
    List<DashboardSubordinate> withoutData = [];

    idToName.forEach((id, name) {
      if (idsWithData.contains(id)) {
        withData.add(DashboardSubordinate(id: id, name: name, hasData: true));
      } else {
        withoutData
            .add(DashboardSubordinate(id: id, name: name, hasData: false));
      }
    });

    // Combine: data first, then no data
    unifiedSubordinates = [...withData, ...withoutData];
  }

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
      CalendarAppointment(
          time: '10:00 AM', title: 'Meeting', client: 'Client A'),
      CalendarAppointment(
          time: '02:30 PM', title: 'Site Visit', client: 'Client B'),
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
      try {
        var decoded = jsonDecode(responseModel.responseJson);
        homeModel = DashboardModel.fromJson(decoded);
      } catch (e) {
        CustomSnackBar.error(errorList: ["Data parsing error: $e"]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    _configureDashboardStats();
    update();
  }

  // Lead Stats State
  String selectedLeadStatsTab =
      'my'; // 'my', 'all_team', or specific staff name
  List<String> subordinateNames = []; // List of staff names to show as tabs

  // Store computed stats for switching
  List<LeadJourneyStep> _journeySelf = [];
  List<LeadJourneyStep> _journeyAllTeam = [];
  Map<String, List<LeadJourneyStep>> _journeyPerSubordinate = {};

  void changeLeadStatsTab(String tab) {
    selectedLeadStatsTab = tab;
    // Update the displayed stats in newStats
    if (tab == 'my') {
      newStats.leadJourney = _journeySelf;
    } else if (tab == 'all_team') {
      newStats.leadJourney = _journeyAllTeam;
    } else {
      // Specific subordinate
      newStats.leadJourney = _journeyPerSubordinate[tab] ?? [];
    }
    update();
  }

  void _configureDashboardStats() {
    // 0. Extract Unified Subordinates (Goals + Leads)
    _extractUnifiedSubordinates();

    // 1. Extract Lead Statistics (Lead Journey & Pie Chart) from Real Data
    _journeySelf = [];
    _journeyAllTeam = [];
    _journeyPerSubordinate = {};
    subordinateNames = [];
    Map<String, int> pie = {};

    // Populate subordinate names from unified list ensuring comprehensive coverage
    subordinateNames = unifiedSubordinates.map((e) => e.name).toList();

    print("DEBUG: Configuring Dashboard Stats");

    // --- SELF STATS (Only Assigned Leads) ---
    // Prioritize leadsStatsFromTasks which contains only leads assigned to the user
    var leadsSourceSelf = homeModel.leadsStatsFromTasks;
    if (leadsSourceSelf == null || leadsSourceSelf.isEmpty) {
      leadsSourceSelf = homeModel.data?.leads;
    }

    if (leadsSourceSelf != null) {
      int i = 1;
      for (var lead in leadsSourceSelf) {
        int count = int.tryParse(lead.total ?? '0') ?? 0;
        String label = _mapStatusIdToLabel(lead.status ?? '');

        _journeySelf
            .add(LeadJourneyStep(step: i++, label: label, count: count));
        if (label.isNotEmpty) pie[label] = count;
      }
    }

    // --- SUBORDINATE STATS (ALL TEAM) ---
    var leadsSourceSub = homeModel.leadsStatsFromTasksSubordinates;
    if (leadsSourceSub != null) {
      int i = 1;
      for (var lead in leadsSourceSub) {
        int count = int.tryParse(lead.total ?? '0') ?? 0;
        String label = _mapStatusIdToLabel(lead.status ?? '');
        _journeyAllTeam
            .add(LeadJourneyStep(step: i++, label: label, count: count));
      }
    }

    // --- SUBORDINATE STATS (INDIVIDUAL) ---
    var perSubordinateMap = homeModel.leadsStatsPerSubordinate;
    // Iterate unified list to ensure everyone gets an entry
    for (var sub in unifiedSubordinates) {
      List<DataField>? list = perSubordinateMap?[sub.name];
      List<LeadJourneyStep> steps = [];
      if (list != null) {
        int i = 1;
        for (var lead in list) {
          int count = int.tryParse(lead.total ?? '0') ?? 0;
          String label = _mapStatusIdToLabel(lead.status ?? '');
          steps.add(LeadJourneyStep(step: i++, label: label, count: count));
        }
      }
      _journeyPerSubordinate[sub.name] = steps;
    }

    // Set initial view

    // 2. Mock Data for other cards (Goals, LeadsTasks) to preserve functionality
    // TODO: Map these to real data when required
    LeadsTasksSummary mockSummary = LeadsTasksSummary(
        todayLeads: 5, pendingLeads: 12, todayTasks: 3, pendingTasks: 8);

    List<GoalTarget> mockGoals = [
      GoalTarget(period: 'Today', target: 5000, achieved: 1200),
      GoalTarget(period: 'Month', target: 150000, achieved: 85000),
      GoalTarget(period: 'Year', target: 2000000, achieved: 450000),
    ];

    newStats = DashboardNewStats(
      leadsTasks: mockSummary,
      leadJourney: selectedLeadStatsTab == 'my'
          ? _journeySelf
          : (selectedLeadStatsTab == 'all_team'
              ? _journeyAllTeam
              : (_journeyPerSubordinate[selectedLeadStatsTab] ?? [])),
      goals: mockGoals,
      leadStatusPie: pie,
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

  // Leads & Tasks Card State
  String selectedLeadsCategory = 'leads'; // 'leads' or 'tasks'
  String selectedLeadsMainTab = 'my';
  String selectedLeadsSubTab = 'today'; // 'today' or 'pending'

  void changeLeadsCategory(String category) {
    selectedLeadsCategory = category;
    update();
  }

  void changeLeadsMainTab(String tab) {
    selectedLeadsMainTab = tab;
    update();
  }

  void changeLeadsSubTab(String tab) {
    selectedLeadsSubTab = tab;
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

  String _mapStatusIdToLabel(String status) {
    switch (status) {
      case '1':
        return 'Customer';
      case '2':
        return 'Hot Lead';
      case '3':
        return 'Warm Lead';
      case '4':
        return 'Not Interested';
      case '5':
        return 'Not Reachable';
      case '6':
        return 'Follow Up';
      default:
        return status;
    }
  }
}
