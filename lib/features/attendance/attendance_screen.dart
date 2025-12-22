import 'package:flutter/material.dart';
import 'attendance_service.dart';
import 'attendance_status.dart';

class AttendanceScreen extends StatefulWidget {
  final String authToken;

  const AttendanceScreen({super.key, required this.authToken});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late AttendanceService service;
  AttendanceStatus? status;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    service = AttendanceService(widget.authToken);
    loadStatus();
  }

  Future<void> loadStatus() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      status = await service.getTodayStatus();
    } catch (e) {
      error = e.toString();
    }

    setState(() => loading = false);
  }

  Future<void> punchIn() async {
    setState(() => loading = true);
    try {
      await service.punchIn();
      await loadStatus();
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Punch In Failed: $e')));
      }
    }
  }

  Future<void> punchOut() async {
    setState(() => loading = true);
    try {
      final needsReason = await service.requiresGpsOffReason();
      String? reason;

      if (needsReason) {
        reason = await _askGpsReason();
        if (reason == null || reason.isEmpty) {
          setState(() => loading = false);
          return;
        }
      }

      await service.punchOut(gpsOffReason: reason);
      await loadStatus();
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Punch Out Failed: $e')));
      }
    }
  }

  Future<String?> _askGpsReason() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('GPS was off'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter reason to continue punch-out',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusHeader(status!),
                        const SizedBox(height: 24),

                        if (!status!.punchedIn)
                          _PrimaryButton(
                            text: 'Punch In',
                            icon: Icons.login,
                            onPressed: punchIn,
                          ),

                        if (status!.punchedIn && !status!.punchedOut) ...[
                          Text(
                            'Punched in at',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status!.punchInTime ?? '--',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          _PrimaryButton(
                            text: 'Punch Out',
                            icon: Icons.logout,
                            onPressed: punchOut,
                          ),
                        ],

                        if (status!.punchedIn && status!.punchedOut)
                          const Text(
                            'You have completed attendance for today',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/* -------------------- Widgets -------------------- */

class _StatusHeader extends StatelessWidget {
  final AttendanceStatus status;

  const _StatusHeader(this.status);

  @override
  Widget build(BuildContext context) {
    final label = status.statusLabel ?? 'Today';
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.punchedOut
                ? 'Completed'
                : status.punchedIn
                ? 'In Progress'
                : 'Not Started',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
