import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReachedComponent extends StatefulWidget {
  final Function(String) onStatusChanged;

  const ReachedComponent({
    super.key,
    required this.onStatusChanged,
  });

  @override
  State<ReachedComponent> createState() => _ReachedComponentState();
}

class _ReachedComponentState extends State<ReachedComponent> {
  late SalesTrackerRepo _repo;
  final TextEditingController _altAddressController = TextEditingController();
  final TextEditingController _altReasonController = TextEditingController();
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
      final response = await _repo.markReachedDestination();
      if (response.status) {
        CustomSnackBar.success(successList: ['Marked as reached']);
        widget.onStatusChanged('reached');
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
      final response = await _repo.updateAddress(
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                borderRadius: BorderRadius.circular(12),
              ),
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
    );
  }

  @override
  void dispose() {
    _altAddressController.dispose();
    _altReasonController.dispose();
    super.dispose();
  }
}
