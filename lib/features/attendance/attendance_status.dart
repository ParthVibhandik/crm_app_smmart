class AttendanceStatus {
  final bool punchedIn;
  final bool punchedOut;
  final String? punchInTime;
  final String? statusLabel;

  AttendanceStatus({
    required this.punchedIn,
    required this.punchedOut,
    this.punchInTime,
    this.statusLabel,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      punchedIn: json['punched_in'] == true,
      punchedOut: json['punched_out'] == true,
      punchInTime: json['punch_in'],
      statusLabel: json['status_label'],
    );
  }
}
