import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/helper/biometric_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class DashboardController extends GetxController {
  DashboardRepo dashboardRepo;
  DashboardController({required this.dashboardRepo}) {
    checkBiometrics();
  }

  bool isFaceIdAvailable = false;

  void checkBiometrics() async {
    List<BiometricType> availableBiometrics =
        await BiometricHelper.getAvailableBiometrics();
    
    if (availableBiometrics.contains(BiometricType.face)) {
      isFaceIdAvailable = true;
    }
    update();
  }

  bool isLoading = true;
  bool logoutLoading = false;
  int currentPageIndex = 0;
  DashboardModel homeModel = DashboardModel();

  bool isPunchedIn = false;
  DateTime? punchInTime;
  Duration workedDuration = Duration.zero;
  Timer? _timer;

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadData();
    loadAttendance();
    isLoading = false;
    update();
  }

  void loadAttendance() {
    isPunchedIn = dashboardRepo.apiClient.sharedPreferences
            .getBool(SharedPreferenceHelper.isPunchedIn) ??
        false;
    String? dateStr = dashboardRepo.apiClient.sharedPreferences
        .getString(SharedPreferenceHelper.punchInTime);
    if (dateStr != null && isPunchedIn) {
      punchInTime = DateTime.parse(dateStr);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (punchInTime != null) {
        workedDuration = DateTime.now().difference(punchInTime!);
        update(['attendance_timer']);
      }
    });
  }

  Future<void> punchIn() async {
    bool authenticated = await BiometricHelper.authenticate(
        localizedReason: 'Authenticate to Punch In');
    if (authenticated) {
      isPunchedIn = true;
      punchInTime = DateTime.now();
      await dashboardRepo.apiClient.sharedPreferences
          .setBool(SharedPreferenceHelper.isPunchedIn, true);
      await dashboardRepo.apiClient.sharedPreferences.setString(
          SharedPreferenceHelper.punchInTime, punchInTime.toString());

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await dashboardRepo.apiClient.sharedPreferences
          .setString(SharedPreferenceHelper.lastPunchDate, today);

      _startTimer();
      update();
      CustomSnackBar.success(successList: ['Punched In Successfully!']);
    }
  }

  Future<void> punchOut() async {
    if (isPunchedIn) {
      isPunchedIn = false;
      _timer?.cancel();
      Duration total = DateTime.now().difference(punchInTime!);

      await dashboardRepo.apiClient.sharedPreferences
          .setBool(SharedPreferenceHelper.isPunchedIn, false);
      
      update();

      String formattedTime =
          "${total.inHours}h ${total.inMinutes % 60}m ${total.inSeconds % 60}s";
      
      Get.defaultDialog(
        title: "Punched Out",
        middleText: "You have worked for $formattedTime today.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<dynamic> loadData() async {
    ResponseModel responseModel = await dashboardRepo.getData();
    if (responseModel.status) {
      homeModel =
          DashboardModel.fromJson(jsonDecode(responseModel.responseJson));
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
      await dashboardRepo.apiClient.sharedPreferences
          .setString(SharedPreferenceHelper.accessTokenKey, '');
      await dashboardRepo.apiClient.sharedPreferences
          .setBool(SharedPreferenceHelper.rememberMeKey, false);
      CustomSnackBar.success(successList: [responseModel.message.tr]);
      Get.offAllNamed(RouteHelper.loginScreen);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    logoutLoading = false;
    update();
  }
}
