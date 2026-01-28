class ReminderModel {
  String? relId;
  String? description;
  String? leadName;
  String? date;

  ReminderModel({
    this.relId,
    this.description,
    this.leadName,
    this.date,
  });

  ReminderModel.fromJson(Map<String, dynamic> json) {
    relId = json['rel_id'];
    description = json['description'];
    leadName = json['lead_name'];
    date = json['date'];
  }
}
