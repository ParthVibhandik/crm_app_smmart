class AttendanceStatus {
  final bool punchedIn;
  final bool punchedOut;
  final String? punchInTime;
  final String? punchOutTime;
  final String? statusLabel;

  AttendanceStatus({
    required this.punchedIn,
    required this.punchedOut,
    this.punchInTime,
    this.punchOutTime,
    this.statusLabel,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      punchedIn: json['punched_in'] == true,
      punchedOut: json['punched_out'] == true,
      punchInTime: json['punch_in'],
      punchOutTime: json['punch_out'],
      statusLabel: json['status_label'],
    );
  }
}
