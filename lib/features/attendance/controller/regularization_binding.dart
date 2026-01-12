import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/controller/regularization_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegularizationBinding extends Bindings {
  @override
  void dependencies() {
    final prefs = Get.find<SharedPreferences>();
    final token = prefs.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

    final attendanceService = AttendanceService(token);

    Get.lazyPut(() => RegularizationController(
          attendanceService: attendanceService,
        ));
  }
}
