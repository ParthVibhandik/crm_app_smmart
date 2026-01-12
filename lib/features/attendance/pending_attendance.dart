class PendingAttendance {
  final String id;
  final String? staffId;
  final String? location;
  final String? attendanceDate;
  final String? punchIn;
  final String? punchOut;
  final String? status;
  final int? workDurationMinutes;

  PendingAttendance({
    required this.id,
    this.staffId,
    this.location,
    this.attendanceDate,
    this.punchIn,
    this.punchOut,
    this.status,
    this.workDurationMinutes,
  });

  factory PendingAttendance.fromJson(Map<String, dynamic> json) {
    return PendingAttendance(
      id: json['id']?.toString() ?? '',
      staffId: json['s_id']?.toString(),
      location: json['location']?.toString(),
      attendanceDate: json['attendance_date']?.toString(),
      punchIn: json['punch_in']?.toString(),
      punchOut: json['punch_out']?.toString(),
      status: json['a_status']?.toString(),
      workDurationMinutes: json['work_duration_minutes'] != null
          ? int.tryParse(json['work_duration_minutes'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      's_id': staffId,
      'location': location,
      'attendance_date': attendanceDate,
      'punch_in': punchIn,
      'punch_out': punchOut,
      'a_status': status,
      'work_duration_minutes': workDurationMinutes,
    };
  }
}
