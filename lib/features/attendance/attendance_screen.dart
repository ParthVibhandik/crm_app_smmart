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
    await service.punchIn();
    await loadStatus();
  }

  Future<void> punchOut() async {
    await service.punchOut();
    await loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!status!.punchedIn)
              ElevatedButton(onPressed: punchIn, child: const Text('Punch In')),

            if (status!.punchedIn && !status!.punchedOut) ...[
              Text('Punched in at: ${status!.punchInTime ?? '--'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: punchOut,
                child: const Text('Punch Out'),
              ),
            ],

            if (status!.punchedIn && status!.punchedOut)
              const Text('You have punched out for today'),
          ],
        ),
      ),
    );
  }
}
