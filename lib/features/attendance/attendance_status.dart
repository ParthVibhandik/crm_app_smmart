class AttendanceStatus {
  final bool punchedIn;
  final bool punchedOut;
  final String? punchInTime;
  final String? punchOutTime;
  final String? punchInInLocation;
  final String? attendanceId;

  AttendanceStatus({
    required this.punchedIn,
    required this.punchedOut,
    this.punchInTime,
    this.punchOutTime,
    this.punchInInLocation,
    this.attendanceId,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      punchedIn: json['is_punched_in'] ?? false,
      punchedOut: json['punch_out_time'] != null,
      punchInTime: json['punch_in_time'],
      punchOutTime: json['punch_out_time'],
      punchInInLocation: json['punch_in_location'],
      attendanceId: json['attendance_id']?.toString(),
    );
  }
}
