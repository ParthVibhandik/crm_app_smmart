import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/sales_tracker/model/trip_session.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndTripScreen extends StatefulWidget {
  const EndTripScreen({super.key});

  @override
  State<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends State<EndTripScreen> {
  late SalesTrackerRepo _salesTrackerRepo;
  bool _isSubmitting = false;
  final TextEditingController _callRemarkController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _ensureRepo();
  }

  @override
  void dispose() {
    _callRemarkController.dispose();
    super.dispose();
  }

  void _ensureRepo() {
    try {
      _salesTrackerRepo = Get.find<SalesTrackerRepo>();
    } catch (_) {
      _salesTrackerRepo = SalesTrackerRepo(apiClient: Get.find<ApiClient>());
      Get.put(_salesTrackerRepo);
    }
  }

  Future<void> _endTrip() async {
    final remark = _callRemarkController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      final response = await _salesTrackerRepo.endTrip(callRemark: remark);
      if (response.status) {
        CustomSnackBar.success(successList: ['Trip ended successfully']);
        // Clear any stored trip session data
        await TripSession.clearActiveTrip();
        // Navigate to dashboard
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
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteHelper.dashboardScreen);
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'End Trip'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.flag_outlined,
                                size: 28, color: Colors.red),
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
        ),
      ),
    );
  }
}
