import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/view/manual_punch_out_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardRepo dashboardRepo;
  DashboardController({required this.dashboardRepo});

  bool isLoading = true;
  bool logoutLoading = false;
  int currentPageIndex = 0;
  DashboardModel homeModel = DashboardModel();

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
    
    _checkPendingPunchOut();
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

  Future<void> _checkPendingPunchOut() async {
    try {
      String token = dashboardRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ?? '';
      if (token.isEmpty) return;

      final attendanceService = AttendanceService(token);
      final pendingData = await attendanceService.getPendingManualPunchOut();

      if (pendingData != null) {
        Get.dialog(
          ManualPunchOutDialog(
            attendanceId: pendingData['attendance_id'].toString(),
            attendanceDate: pendingData['attendance_date'].toString(),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Error checking pending punch out: $e');
    }
  }
}
