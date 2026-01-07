import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';

class ManualPunchOutDialog extends StatefulWidget {
  final String attendanceId;
  final String attendanceDate;

  const ManualPunchOutDialog({
    Key? key,
    required this.attendanceId,
    required this.attendanceDate,
  }) : super(key: key);

  @override
  State<ManualPunchOutDialog> createState() => _ManualPunchOutDialogState();
}

class _ManualPunchOutDialogState extends State<ManualPunchOutDialog> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Block back button
      child: AlertDialog(
        title: Text(
          "Update Pending Punch Out",
          style: semiBoldLarge.copyWith(color: ColorResources.colorBlack),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You forgot to punch out on ${widget.attendanceDate}. Please enter the time.",
              style: regularDefault.copyWith(color: ColorResources.getTextColor()),
            ),
            const SizedBox(height: Dimensions.space15),
            Text(
              "Punch Out Time",
              style: semiBoldDefault.copyWith(color: ColorResources.getLabelTextColor()),
            ),
            const SizedBox(height: Dimensions.space5),
            GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 18, minute: 0),
                );
                if (picked != null) {
                  // Construct full DateTime string: YYYY-MM-DD HH:MM:SS
                  // We use the attendance date provided by the backend
                  final timeStr =
                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
                  timeController.text = "${widget.attendanceDate} $timeStr";
                }
              },
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: timeController,
                  readOnly: true,
                  hintText: "Select Time",
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(height: Dimensions.space15),
            Text(
              "Reason",
              style: semiBoldDefault.copyWith(color: ColorResources.getLabelTextColor()),
            ),
            const SizedBox(height: Dimensions.space5),
            CustomTextField(
              controller: reasonController,
              hintText: "E.g. Forgot to punch out",
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RoundedButton(
                  text: "Submit",
                  press: _submit,
                  color: ColorResources.primaryColor,
                  textColor: ColorResources.colorWhite,
                ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (timeController.text.isEmpty) {
      CustomSnackBar.error(errorList: ['Please select punch out time']);
      return;
    }
    if (reasonController.text.isEmpty) {
      CustomSnackBar.error(errorList: ['Please enter a reason']);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // Use the correct key for access token
      final token = prefs.getString('access_token') ?? ''; 
      
      final service = AttendanceService(token); 
      await service.submitManualPunchOut(timeController.text, reasonController.text);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        CustomSnackBar.success(successList: ['Manual punch-out submitted successfully']);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: [e.toString().replaceAll('Exception: ', '')]);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
