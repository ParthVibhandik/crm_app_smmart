class LeadsTasksSummary {
  final int todayLeads;
  final int pendingLeads;
  final int todayTasks;
  final int pendingTasks;

  LeadsTasksSummary({
    this.todayLeads = 0,
    this.pendingLeads = 0,
    this.todayTasks = 0,
    this.pendingTasks = 0,
  });
}

class LeadJourneyStep {
  final int step;
  final String label;
  final int count;

  LeadJourneyStep({
    required this.step,
    required this.label,
    required this.count,
  });
}

class GoalTarget {
  final String period; // Today, Month, Year
  final double target;
  final double achieved;
  
  double get remaining => (target - achieved) < 0 ? 0 : (target - achieved);
  double get progress => target == 0 ? 0 : (achieved / target);

  GoalTarget({
    required this.period,
    required this.target,
    required this.achieved,
  });
}

class CalendarAppointment {
  final String time;
  final String title;
  final String client;
  
  CalendarAppointment({
    required this.time,
    required this.title,
    required this.client,
  });
}

class DashboardNewStats {
  LeadsTasksSummary leadsTasks;
  List<LeadJourneyStep> leadJourney;
  List<GoalTarget> goals;
  Map<String, int> leadStatusPie; // "Contacted": 10
  
  DashboardNewStats({
    required this.leadsTasks,
    required this.leadJourney,
    required this.goals,
    required this.leadStatusPie,
  });
  
  // Factory for empty/mock
  factory DashboardNewStats.empty() {
    return DashboardNewStats(
      leadsTasks: LeadsTasksSummary(),
      leadJourney: [],
      goals: [],
      leadStatusPie: {},
    );
  }
}
