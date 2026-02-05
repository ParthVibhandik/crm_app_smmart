class GoalDetailModel {
  bool? status;
  GoalDetailData? data;

  GoalDetailModel({this.status, this.data});

  GoalDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? GoalDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GoalDetailData {
  String? id;
  String? subject;
  String? description;
  String? startDate;
  String? endDate;
  String? goalType;
  String? contractType;
  Achievement? achievement;
  String? notifyWhenFail;
  String? notifyWhenAchieve;
  String? notified;
  String? staffId;
  String? addedFrom;
  String? type;
  String? recurring;
  String? target;

  GoalDetailData({
    this.id,
    this.subject,
    this.description,
    this.startDate,
    this.endDate,
    this.goalType,
    this.contractType,
    this.achievement,
    this.notifyWhenFail,
    this.notifyWhenAchieve,
    this.notified,
    this.staffId,
    this.addedFrom,
    this.type,
    this.recurring,
    this.target,
  });

  GoalDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    subject = json['subject']?.toString();
    description = json['description']?.toString();
    startDate = json['start_date']?.toString();
    endDate = json['end_date']?.toString();
    goalType = json['goal_type']?.toString();
    contractType = json['contract_type']?.toString();
    achievement = json['achievement'] != null
        ? Achievement.fromJson(json['achievement'])
        : null;
    notifyWhenFail = json['notify_when_fail']?.toString();
    notifyWhenAchieve = json['notify_when_achieve']?.toString();
    notified = json['notified']?.toString();
    staffId = json['staff_id']?.toString();
    addedFrom = json['added_from']?.toString();
    type = json['type']?.toString();
    recurring = json['recurring']?.toString();
    target = json['target']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subject'] = subject;
    data['description'] = description;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['goal_type'] = goalType;
    data['contract_type'] = contractType;
    if (achievement != null) {
      data['achievement'] = achievement!.toJson();
    }
    data['notify_when_fail'] = notifyWhenFail;
    data['notify_when_achieve'] = notifyWhenAchieve;
    data['notified'] = notified;
    data['staff_id'] = staffId;
    data['added_from'] = addedFrom;
    data['type'] = type;
    data['recurring'] = recurring;
    data['target'] = target;
    return data;
  }
}

class Achievement {
  int? total;
  String? percent;
  int? progressBarPercent;

  Achievement({this.total, this.percent, this.progressBarPercent});

  Achievement.fromJson(Map<String, dynamic> json) {
    if (json['total'] != null) {
      total = int.tryParse(json['total'].toString());
    }
    percent = json['percent']?.toString();
    if (json['progress_bar_percent'] != null) {
      progressBarPercent = int.tryParse(json['progress_bar_percent'].toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['percent'] = percent;
    data['progress_bar_percent'] = progressBarPercent;
    return data;
  }
}
