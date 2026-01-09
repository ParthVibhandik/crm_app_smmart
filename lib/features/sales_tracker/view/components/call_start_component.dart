import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallStartComponent extends StatefulWidget {
  final Function(String) onStatusChanged;

  const CallStartComponent({
    super.key,
    required this.onStatusChanged,
  });

  @override
  State<CallStartComponent> createState() => _CallStartComponentState();
}

class _CallStartComponentState extends State<CallStartComponent> {
  late SalesTrackerRepo _repo;
  bool _isSubmitting = false;

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

  Future<void> _startCall() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _repo.callStart();
      if (response.status) {
        CustomSnackBar.success(successList: ['Call started successfully']);
        widget.onStatusChanged('call_started');
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.call_outlined, size: 28, color: Colors.blue),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Start your call with the customer',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                            softWrap: true,
                          ),
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
    );
  }
}
