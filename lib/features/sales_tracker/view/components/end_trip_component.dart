import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/sales_tracker/model/trip_session.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndTripComponent extends StatefulWidget {
  final Function(String) onStatusChanged;

  const EndTripComponent({
    super.key,
    required this.onStatusChanged,
  });

  @override
  State<EndTripComponent> createState() => _EndTripComponentState();
}

class _EndTripComponentState extends State<EndTripComponent> {
  late SalesTrackerRepo _repo;
  bool _isSubmitting = false;
  final TextEditingController _callRemarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repo = Get.find<SalesTrackerRepo>();
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _endTrip() async {
    final remark = _callRemarkController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      final response = await _repo.endTrip(callRemark: remark);
      if (response.status) {
        CustomSnackBar.success(successList: ['Trip ended successfully']);
        await TripSession.clearActiveTrip();
        Get.offAllNamed(RouteHelper.dashboardScreen);
      } else {
        CustomSnackBar.error(errorList: [response.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error ending trip: $e']);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flag_outlined, size: 28, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'End your trip',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'When you are done with the call, you can end the trip.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _callRemarkController,
                      labelText: 'Call Remark',
                      hintText: 'Enter call remark or notes',
                      maxLines: 3,
                      onChanged: (val) {},
                    ),
                    const SizedBox(height: 24),
                    _primaryButton(
                      label: 'End Trip',
                      onTap: _isSubmitting ? null : _endTrip,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callRemarkController.dispose();
    super.dispose();
  }
}
