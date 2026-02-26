import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';

class StaffGoalsModel {
  bool? status;
  String? message;
  List<Goal>? goals;

  StaffGoalsModel({this.status, this.message, this.goals});

  StaffGoalsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // In flutex_admin_api/goals, the goals might be directly in a 'goals' key or top level list
    // Based on dashboard model, it has 'goals' with 'self_goals' etc.
    // The user said "send his id... fetch his goals". It might return a list of goals directly.
    // I will assume the standard response structure from other lists.
    // But wait, the dashboard model shows "goals" object with self/assigned/subordinate.
    // If we filter by ID, we likely get just a list of goal objects.
    if (json['data'] != null) {
      goals = <Goal>[];
      json['data'].forEach((v) {
        goals!.add(Goal.fromJson(v));
      });
    } else if (json['goals'] != null) {
      // Support if it comes in 'goals' key
      if (json['goals'] is List) {
        goals = <Goal>[];
        json['goals'].forEach((v) {
          goals!.add(Goal.fromJson(v));
        });
      }
    }
  }
}
