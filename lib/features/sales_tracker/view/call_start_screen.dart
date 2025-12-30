import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutex_admin/features/sales_tracker/view/end_trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallStartScreen extends StatefulWidget {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> {
  late SalesTrackerRepo _salesTrackerRepo;
  bool _isSubmitting = false;
  bool _isEnding = false;

  Widget _primaryButton(
      {required String label, required VoidCallback? onTap, Color? color}) {
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

  void _ensureRepo() {
    try {
      _salesTrackerRepo = Get.find<SalesTrackerRepo>();
    } catch (_) {
      _salesTrackerRepo = SalesTrackerRepo(apiClient: Get.find<ApiClient>());
      Get.put(_salesTrackerRepo);
    }
  }

  Future<void> _confirmAndEndTrip() async {
    final remarkController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End trip now?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'This will end your current trip. You can add an optional remark.'),
            const SizedBox(height: 12),
            TextField(
              controller: remarkController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Call Remark (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isEnding = true);
    try {
      final remark = remarkController.text.trim();
      final res = await _salesTrackerRepo.endTrip(callRemark: remark);
      if (res.status) {
        Get.offAllNamed(RouteHelper.dashboardScreen);
      } else {
        CustomSnackBar.error(errorList: [res.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error ending trip: $e']);
    } finally {
      if (mounted) setState(() => _isEnding = false);
    }
  }

  Future<void> _startCall() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _salesTrackerRepo.callStart();
      if (response.status) {
        CustomSnackBar.success(successList: ['Call started successfully']);
        // Navigate to end trip screen
        Get.to(() => const EndTripScreen());
      } else {
        CustomSnackBar.error(errorList: [response.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error starting call: $e']);
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
        appBar: const CustomAppBar(title: 'Call Start'),
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
                            Icon(Icons.call_outlined,
                                size: 28, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Start your call with the customer',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _primaryButton(
                          label: 'Start Call',
                          onTap: _isSubmitting ? null : _startCall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (_isSubmitting || _isEnding) ? null : _confirmAndEndTrip,
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('End Trip'),
          backgroundColor: Colors.red,
        ),
      ),
    );
  }
}
