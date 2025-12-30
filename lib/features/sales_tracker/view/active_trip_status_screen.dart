import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutex_admin/features/sales_tracker/view/call_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActiveTripStatusScreen extends StatefulWidget {
  const ActiveTripStatusScreen({super.key});

  @override
  State<ActiveTripStatusScreen> createState() => _ActiveTripStatusScreenState();
}

class _ActiveTripStatusScreenState extends State<ActiveTripStatusScreen> {
  late SalesTrackerRepo _salesTrackerRepo;
  final TextEditingController _altAddressController = TextEditingController();
  final TextEditingController _altReasonController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEnding = false;

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

  Widget _outlineButton({required String label, required VoidCallback? onTap}) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _markReached() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _salesTrackerRepo.markReachedDestination();
      if (response.status) {
        CustomSnackBar.success(successList: ['Marked as reached']);
        Get.to(() => const CallStartScreen());
      } else {
        CustomSnackBar.error(errorList: [response.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error marking reached: $e']);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateAddress() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _salesTrackerRepo.updateAddress(
        altAddress: _altAddressController.text.trim(),
        altReason: _altReasonController.text.trim(),
      );
      if (response.status) {
        CustomSnackBar.success(successList: ['Address updated successfully']);
        _altAddressController.clear();
        _altReasonController.clear();
      } else {
        CustomSnackBar.error(errorList: [response.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error updating address: $e']);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteHelper.dashboardScreen);
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Active Trip'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Icon(Icons.place_outlined,
                                size: 28, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Have you reached the destination?',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _primaryButton(
                                label: 'Yes',
                                onTap: _isSubmitting ? null : _markReached,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _outlineButton(
                                label: 'No',
                                onTap: _isSubmitting ? null : () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Icon(Icons.edit_location_alt_outlined,
                                size: 24, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Update Address',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _altAddressController,
                          labelText: 'Alternate Address',
                          hintText: 'Enter new address',
                          maxLines: 2,
                          onChanged: (val) {},
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _altReasonController,
                          labelText: 'Reason',
                          hintText: 'Why are you changing the address?',
                          maxLines: 2,
                          onChanged: (val) {},
                        ),
                        const SizedBox(height: 12),
                        _primaryButton(
                          label: 'Update Address',
                          onTap: _isSubmitting ? null : _updateAddress,
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

  @override
  void dispose() {
    _altAddressController.dispose();
    _altReasonController.dispose();
    super.dispose();
  }
}
