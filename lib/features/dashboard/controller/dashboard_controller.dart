import 'dart:async';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardRepo dashboardRepo;
  DashboardController({required this.dashboardRepo});

  bool isLoading = true;
  bool logoutLoading = false;
  int currentPageIndex = 0;
  DashboardModel homeModel = DashboardModel();

  // Calendar State
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  bool isAttendanceLoading = false;
  String? punchInTime;
  String? punchOutTime;

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
