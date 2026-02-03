class CreateGoalModel {
  String? subject;
  String? goalType;
  String? type; // 'custom' or others
  String? achievement;
  String? recurring; // 0 or 1?
  String? description;
  String? staffId;
  String? startDate;
  String? endDate;

  CreateGoalModel({
    this.subject,
    this.goalType,
    this.type = 'custom',
    this.achievement,
    this.recurring = '0',
    this.description,
    this.staffId,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'goal_type': goalType,
      'type': type,
      'achievement': achievement,
      'recurring': recurring,
      'description': description,
      'staff_id': staffId,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
