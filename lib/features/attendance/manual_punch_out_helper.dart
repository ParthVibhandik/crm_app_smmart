import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'attendance_service.dart';

class ManualPunchOutHelper {
  static Future<void> checkAndShow(BuildContext context, String authToken) async {
    final service = AttendanceService(authToken);

    try {
      final data = await service.getPendingManualPunchOut();
      
      if (data != null && data['requires_manual_punch_out'] == true) {
        if (context.mounted) {
          _showMandatoryPopup(context, service);
        }
      }
    } catch (e) {
      print('Failed to check manual punch out: $e');
    }
  }

  static void _showMandatoryPopup(BuildContext context, AttendanceService service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // ❌ No close, No skip
          child: _ManualPunchOutDialog(service: service),
        );
      },
    );
  }
}

class _ManualPunchOutDialog extends StatefulWidget {
  final AttendanceService service;

  const _ManualPunchOutDialog({required this.service});

  @override
  State<_ManualPunchOutDialog> createState() => _ManualPunchOutDialogState();
}

class _ManualPunchOutDialogState extends State<_ManualPunchOutDialog> {
  final TextEditingController _reasonController = TextEditingController();
  TimeOfDay? _selectedTime;
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_selectedTime == null) {
      setState(() => _error = 'Please select a punch-out time');
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a reason');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // Format time as HH:mm
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
      // Sending full datetime or just time? Endpoint likely expects what the backend needs. 
      // User prompt says "Punch-out time picker". 
      // I'll send HH:mm formatted string or ISO depending on backend expectation. 
      // "Punch-out time" usually implies the time of day. 
      // Backend Logic: "punch_out IS NULL".
      // I'll send HH:mm:ss for now using local time.
      final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

      await widget.service.submitManualPunchOut(timeString, _reasonController.text.trim());

      // Success
      if (mounted) {
        Navigator.of(context).pop(); // Close popup
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Waiting for manager approval'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚠️ Manual Punch-Out Required'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You forgot to punch out previously. Please submit your punch-out time and reason to proceed.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            // Time Picker
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                    _error = null;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Punch-out Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _selectedTime?.format(context) ?? 'Select Time',
                  style: TextStyle(
                    color: _selectedTime == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reason Field
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Why did you forget?',
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // ❌ No close, No skip, so only Submit button.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _submitting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit'),
          ),
        ),
      ],
    );
  }
}
