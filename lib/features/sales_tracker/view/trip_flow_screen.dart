import 'dart:convert';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutex_admin/features/sales_tracker/view/components/reached_component.dart';
import 'package:flutex_admin/features/sales_tracker/view/components/call_start_component.dart';
import 'package:flutex_admin/features/sales_tracker/view/components/end_trip_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripFlowScreen extends StatefulWidget {
  const TripFlowScreen({super.key});

  @override
  State<TripFlowScreen> createState() => _TripFlowScreenState();
}

class _TripFlowScreenState extends State<TripFlowScreen> {
  late SalesTrackerRepo _repo;
  bool _isLoading = true;
  String _currentStatus = 'not_started';
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _repo = Get.find<SalesTrackerRepo>();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final response = await _repo.getTripStatus();
      if (response.status) {
        setState(() {
          _currentStatus = _extractStatus(response.responseJson);
        });
      }
    } catch (e) {
      print('Error loading status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _extractStatus(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        if (decoded['data'] is Map && decoded['data']['status'] is String) {
          return _normalizeStatus(decoded['data']['status']);
        }
        if (decoded['status'] is String) {
          return _normalizeStatus(decoded['status']);
        }
      } else if (decoded is String) {
        return _normalizeStatus(decoded);
      }
    } catch (_) {}

    final lowered = raw.toLowerCase();
    if (lowered.contains('not_started')) return 'not_started';
    if (lowered.contains('started') && !lowered.contains('call'))
      return 'started';
    if (lowered.contains('reached')) return 'reached';
    if (lowered.contains('call') && lowered.contains('started'))
      return 'call_started';
    return 'not_started';
  }

  String _normalizeStatus(String s) {
    final lowered = s.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    if (lowered.contains('call') && lowered.contains('started'))
      return 'call_started';
    if (lowered == 'not_started') return 'not_started';
    if (lowered == 'started') return 'started';
    if (lowered == 'reached') return 'reached';
    return 'not_started';
  }

  void _onStatusChanged(String newStatus) {
    setState(() => _currentStatus = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStatus == 'not_started') {
          return true; // Allow normal back
        }
        Get.offAllNamed(RouteHelper.dashboardScreen);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _getTitle(),
        ),
        body: _isLoading ? const CustomLoader() : _buildCurrentComponent(),
        floatingActionButton: (_currentStatus == 'not_started' ||
                _currentStatus == 'call_started')
            ? null
            : FloatingActionButton.extended(
                onPressed: _isEnding ? null : _confirmAndEndTrip,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('End Trip'),
                backgroundColor: Colors.red,
              ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentStatus) {
      case 'started':
        return 'Active Trip';
      case 'reached':
        return 'Call Start';
      case 'call_started':
        return 'End Trip';
      default:
        return 'Sales Trip Tracker';
    }
  }

  Widget _buildCurrentComponent() {
    switch (_currentStatus) {
      case 'started':
        return ReachedComponent(
          onStatusChanged: _onStatusChanged,
        );
      case 'reached':
        return CallStartComponent(
          onStatusChanged: _onStatusChanged,
        );
      case 'call_started':
        return EndTripComponent(
          onStatusChanged: _onStatusChanged,
        );
      default:
        // not_started - show map or redirect back to main sales tracker
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active trip'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        );
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
      final res = await _repo.endTrip(callRemark: remark);
      if (res.status) {
        // Navigate to dashboard after successful end
        Get.offAllNamed(RouteHelper.dashboardScreen);
      } else {
        Get.snackbar('Failed', 'Unable to end trip. Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isEnding = false);
    }
  }
}
