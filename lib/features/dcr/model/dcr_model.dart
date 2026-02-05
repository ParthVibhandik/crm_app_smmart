class DCRModel {
  final String? leadName;
  final String? callStart;
  final String? duration;
  final String? type;
  final String? prevStatus;
  final String? currentStatus;
  final String? remarks;

  DCRModel({
    this.leadName,
    this.callStart,
    this.duration,
    this.type,
    this.prevStatus,
    this.currentStatus,
    this.remarks,
  });

  factory DCRModel.fromJson(Map<String, dynamic> json) {
    return DCRModel(
      leadName: json['lead_name']?.toString(),
      callStart: json['call_start']?.toString(),
      duration: json['duration']?.toString(),
      type: json['type']?.toString(),
      prevStatus: json['prev_status']?.toString(),
      currentStatus: json['current_status']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }
}
