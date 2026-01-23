import 'package:flutex_admin/core/utils/url_container.dart';

class DashboardModel {
  DashboardModel({
    bool? status,
    String? message,
    Goals? goals,
    Overview? overview,
    Data? data,
    Staff? staff,
    MenuItems? menuItems,
    LeadsTasks? leadsTasks,
  }) {
    _status = status;
    _message = message;
    _goals = goals;
    _overview = overview;
    _data = data;
    _staff = staff;
    _menuItems = menuItems;
    _leadsTasks = leadsTasks;
    _leadsStatsFromTasks = null;
  }

  DashboardModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _goals = json['goals'] != null ? Goals.fromJson(json['goals']) : null;
    _overview =
        json['overview'] != null ? Overview.fromJson(json['overview']) : null;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _staff = json['staff'] != null ? Staff.fromJson(json['staff']) : null;
    _menuItems = json['menu_items'] != null
        ? MenuItems.fromJson(json['menu_items'])
        : null;

    // Logic for leads_tasks
    var leadsTasksJson = json['leads_tasks'];
    if (leadsTasksJson == null && json['data'] != null) {
      leadsTasksJson = json['data']['leads_tasks'];
    }

    if (leadsTasksJson != null) {
      // Try to parse as LeadsTasks object (lists of items)
      try {
        // Only if it has specific keys we expect, otherwise simple map extraction might be preferred
        // But LeadsTasks.fromJson is permissive
        if (leadsTasksJson is Map) {
          _leadsTasks =
              LeadsTasks.fromJson(leadsTasksJson as Map<String, dynamic>);
        }
      } catch (e) {
        // ignore
      }

      // ALSO try to parse stats from the lists inside leads_tasks
      if (leadsTasksJson is Map) {
        _leadsStatsFromTasks = [];
        Map<String, int> statusCounts = {};
        Set<String> processedIds = {};

        // Helper function to process lists with deduplication
        void processList(dynamic list, Set<String> processedIdsRef,
            Map<String, int> countsRef) {
          if (list is List) {
            for (var item in list) {
              if (item is Map && item.containsKey('status')) {
                String id = item['id']?.toString() ?? '';
                // Deduplicate by ID if present
                if (id.isNotEmpty) {
                  if (processedIdsRef.contains(id)) continue;
                  processedIdsRef.add(id);
                }

                String status = item['status'].toString();
                countsRef[status] = (countsRef[status] ?? 0) + 1;
              }
            }
          }
        }

        // Process known lists for SELF
        if (leadsTasksJson.containsKey('today_self')) {
          processList(leadsTasksJson['today_self'], processedIds, statusCounts);
        }
        if (leadsTasksJson.containsKey('pending_self')) {
          processList(
              leadsTasksJson['pending_self'], processedIds, statusCounts);
        }

        // Convert map to List<DataField>
        statusCounts.forEach((key, value) {
          _leadsStatsFromTasks!
              .add(DataField(status: key, total: value.toString()));
        });

        // --- Subordinates (Team & Individual) Stats Logic ---
        _leadsStatsFromTasksSubordinates = [];
        _leadsStatsPerSubordinate = {};

        Map<String, int> subStatusCountsTotal = {};
        Set<String> processedSubIdsTotal = {};

        // Helper for subordinates maps (Staff Name -> List)
        void processSubordMap(dynamic mapData) {
          if (mapData is Map) {
            mapData.forEach((staffName, list) {
              // 1. Aggregate for Total "Team" View
              processList(list, processedSubIdsTotal, subStatusCountsTotal);

              // 2. Aggregate for Individual View
              if (!_leadsStatsPerSubordinate!.containsKey(staffName)) {
                _leadsStatsPerSubordinate![staffName] = [];
              }

              // We need a temporary map for this specific staff/call to accumulate properly
              // But since we might hit 'today' and 'pending' separate calls for same staff,
              // we can't just overwrite.
              // We need to parse list first, then ADD to the existing stats or build a Map<String, int> for each staff first.
            });
          }
        }

        // Better approach: First build Map<StaffName, Map<Status, Count>>
        Map<String, Map<String, int>> perStaffCounts = {};
        Map<String, Set<String>> perStaffIds = {};

        void processSubordMapNew(dynamic mapData) {
          if (mapData is Map) {
            mapData.forEach((staffName, list) {
              if (!perStaffCounts.containsKey(staffName))
                perStaffCounts[staffName] = {};
              if (!perStaffIds.containsKey(staffName))
                perStaffIds[staffName] = {};

              processList(
                  list, perStaffIds[staffName]!, perStaffCounts[staffName]!);

              // Also add to totals
              processList(list, processedSubIdsTotal, subStatusCountsTotal);
            });
          }
        }

        if (leadsTasksJson.containsKey('today_subords')) {
          processSubordMapNew(leadsTasksJson['today_subords']);
        }
        if (leadsTasksJson.containsKey('pending_subords')) {
          processSubordMapNew(leadsTasksJson['pending_subords']);
        }

        // Convert totals
        subStatusCountsTotal.forEach((key, value) {
          _leadsStatsFromTasksSubordinates!
              .add(DataField(status: key, total: value.toString()));
        });

        // Convert individuals
        perStaffCounts.forEach((staffName, counts) {
          List<DataField> fields = [];
          counts.forEach((key, value) {
            fields.add(DataField(status: key, total: value.toString()));
          });
          _leadsStatsPerSubordinate![staffName] = fields;
        });
        // Excluded tasks_subords/subordinates_tasks to avoid mixing Tasks with Lead Stats
        // and to prevent incorrectly counting Tasks as Leads.
      }
    }

    // Capture tasks from separate 'tasks' key if present
    var tasksData = json['tasks'];
    if (tasksData == null && json['data'] != null) {
      tasksData = json['data']['tasks'];
    }

    if (tasksData != null) {
      // Ensure _leadsTasks is initialized
      _leadsTasks ??= LeadsTasks();

      // Check self_tasks
      if (tasksData['self_tasks'] != null) {
        _leadsTasks!.selfTasks = [];
        if (tasksData['self_tasks'] is List) {
          tasksData['self_tasks'].forEach(
              (v) => _leadsTasks!.selfTasks!.add(LeadTaskItem.fromJson(v)));
        }
      }

      // Check subordinates_tasks (or subordinate_tasks/subordinate_goals variants)
      // User said "subordinate_tasks", checking plural too just in case
      var subTasks =
          tasksData['subordinate_tasks'] ?? tasksData['subordinates_tasks'];

      if (subTasks != null && subTasks is Map) {
        _leadsTasks!.subordinatesTasks = {};
        subTasks.forEach((key, value) {
          if (value is List) {
            _leadsTasks!.subordinatesTasks![key] =
                value.map((v) => LeadTaskItem.fromJson(v)).toList();
          }
        });
      }
    }
  }
  bool? _status;
  String? _message;
  Goals? _goals;
  Overview? _overview;
  Data? _data;
  Staff? _staff;
  MenuItems? _menuItems;
  LeadsTasks? _leadsTasks;
  List<DataField>? _leadsStatsFromTasks;

  List<DataField>? _leadsStatsFromTasksSubordinates;
  Map<String, List<DataField>>? _leadsStatsPerSubordinate;

  bool? get status => _status;
  String? get message => _message;
  Goals? get goals => _goals;
  Overview? get overview => _overview;
  Data? get data => _data;
  Staff? get staff => _staff;
  MenuItems? get menuItems => _menuItems;
  LeadsTasks? get leadsTasks => _leadsTasks;
  List<DataField>? get leadsStatsFromTasks => _leadsStatsFromTasks;
  List<DataField>? get leadsStatsFromTasksSubordinates =>
      _leadsStatsFromTasksSubordinates;
  Map<String, List<DataField>>? get leadsStatsPerSubordinate =>
      _leadsStatsPerSubordinate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_overview != null) {
      map['overview'] = _overview?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    if (_staff != null) {
      map['staff'] = _staff?.toJson();
    }
    if (_menuItems != null) {
      map['menu_items'] = _menuItems?.toJson();
    }
    if (_goals != null) {
      map['goals'] = _goals?.toJson();
    }
    if (_leadsTasks != null) {
      map['leads_tasks'] = _leadsTasks?.toJson();
    }
    // Note: _leadsStatsFromTasks is derived from leads_tasks, so we don't strictly need to serialize it
    // back to a separate field if we preserve leads_tasks.
    // But for completeness if we want to inspect it:
    if (_leadsStatsFromTasks != null) {
      map['leads_stats_map'] =
          _leadsStatsFromTasks!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LeadsTasks {
  List<LeadTaskItem>? todaySelf;
  List<LeadTaskItem>? pendingSelf;
  Map<String, List<LeadTaskItem>>? todaySubords;
  Map<String, List<LeadTaskItem>>? pendingSubords;
  // Tasks
  List<LeadTaskItem>? selfTasks;
  Map<String, List<LeadTaskItem>>? subordinatesTasks;

  LeadsTasks({
    this.todaySelf,
    this.pendingSelf,
    this.todaySubords,
    this.pendingSubords,
    this.selfTasks,
    this.subordinatesTasks,
  });

  LeadsTasks.fromJson(Map<String, dynamic> json) {
    // leads
    if (json['today_self'] != null) {
      todaySelf = [];
      if (json['today_self'] is List) {
        json['today_self']
            .forEach((v) => todaySelf!.add(LeadTaskItem.fromJson(v)));
      }
    }
    if (json['pending_self'] != null) {
      pendingSelf = [];
      if (json['pending_self'] is List) {
        json['pending_self']
            .forEach((v) => pendingSelf!.add(LeadTaskItem.fromJson(v)));
      }
    }
    // subord leads - dynamic keys (staff names)
    if (json['today_subords'] != null && json['today_subords'] is Map) {
      todaySubords = {};
      json['today_subords'].forEach((key, value) {
        if (value is List) {
          todaySubords![key] =
              value.map((v) => LeadTaskItem.fromJson(v)).toList();
        }
      });
    }
    if (json['pending_subords'] != null && json['pending_subords'] is Map) {
      pendingSubords = {};
      json['pending_subords'].forEach((key, value) {
        if (value is List) {
          pendingSubords![key] =
              value.map((v) => LeadTaskItem.fromJson(v)).toList();
        }
      });
    }

    // tasks
    // Check for "self_tasks" OR "tasks_self" or similar variants if strictly not found
    if (json['self_tasks'] != null) {
      selfTasks = [];
      if (json['self_tasks'] is List) {
        json['self_tasks']
            .forEach((v) => selfTasks!.add(LeadTaskItem.fromJson(v)));
      }
    } else if (json['tasks_self'] != null) {
      // Fallback check
      selfTasks = [];
      if (json['tasks_self'] is List) {
        json['tasks_self']
            .forEach((v) => selfTasks!.add(LeadTaskItem.fromJson(v)));
      }
    }

    if (json['subordinates_tasks'] != null &&
        json['subordinates_tasks'] is Map) {
      subordinatesTasks = {};
      json['subordinates_tasks'].forEach((key, value) {
        if (value is List) {
          subordinatesTasks![key] =
              value.map((v) => LeadTaskItem.fromJson(v)).toList();
        }
      });
    } else if (json['tasks_subords'] != null && json['tasks_subords'] is Map) {
      // Fallback
      subordinatesTasks = {};
      json['tasks_subords'].forEach((key, value) {
        if (value is List) {
          subordinatesTasks![key] =
              value.map((v) => LeadTaskItem.fromJson(v)).toList();
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (todaySelf != null) {
      data['today_self'] = todaySelf!.map((v) => v.toJson()).toList();
    }
    if (pendingSelf != null) {
      data['pending_self'] = pendingSelf!.map((v) => v.toJson()).toList();
    }
    // Subords and others can be added if needed for serialization, mostly read-only
    return data;
  }
}

class Goals {
  Goals({
    List<Goal>? selfGoals,
    List<Goal>? assignedGoals,
    List<Goal>? subordinatesGoals,
  }) {
    _selfGoals = selfGoals;
    _assignedGoals = assignedGoals;
    _subordinatesGoals = subordinatesGoals;
  }

  Goals.fromJson(dynamic json) {
    if (json['self_goals'] != null) {
      _selfGoals = [];
      json['self_goals'].forEach((v) {
        _selfGoals?.add(Goal.fromJson(v));
      });
    }
    if (json['assigned_goals'] != null) {
      _assignedGoals = [];
      json['assigned_goals'].forEach((v) {
        _assignedGoals?.add(Goal.fromJson(v));
      });
    }
    if (json['subordinates_goals'] != null) {
      _subordinatesGoals = [];
      json['subordinates_goals'].forEach((v) {
        _subordinatesGoals?.add(Goal.fromJson(v));
      });
    }
  }

  List<Goal>? _selfGoals;
  List<Goal>? _assignedGoals;
  List<Goal>? _subordinatesGoals;

  List<Goal>? get selfGoals => _selfGoals;
  List<Goal>? get assignedGoals => _assignedGoals;
  List<Goal>? get subordinatesGoals => _subordinatesGoals;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_selfGoals != null) {
      map['self_goals'] = _selfGoals?.map((v) => v.toJson()).toList();
    }
    if (_assignedGoals != null) {
      map['assigned_goals'] = _assignedGoals?.map((v) => v.toJson()).toList();
    }
    if (_subordinatesGoals != null) {
      map['subordinates_goals'] =
          _subordinatesGoals?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Goal {
  Goal({
    String? id,
    String? subject,
    String? description,
    String? startDate,
    String? endDate,
    String? goalType,
    String? achievement,
    String? staffId,
    String? contractType,
    String? notifyWhenFail,
    String? notifyWhenAchieve,
    String? notified,
    String? addedFrom,
    String? type,
    String? staffFirstname,
    String? staffLastname,
  }) {
    _id = id;
    _subject = subject;
    _description = description;
    _startDate = startDate;
    _endDate = endDate;
    _goalType = goalType;
    _achievement = achievement;
    _staffId = staffId;
    _contractType = contractType;
    _notifyWhenFail = notifyWhenFail;
    _notifyWhenAchieve = notifyWhenAchieve;
    _notified = notified;
    _addedFrom = addedFrom;
    _type = type;
    _staffFirstname = staffFirstname;
    _staffLastname = staffLastname;
  }

  Goal.fromJson(dynamic json) {
    _id = json['id'];
    _subject = json['subject'];
    _description = json['description'];
    _startDate = json['start_date'];
    _endDate = json['end_date'];
    _goalType = json['goal_type'];
    _achievement = json['achievement'];
    _staffId = json['staff_id'];
    _contractType = json['contract_type'];
    _notifyWhenFail = json['notify_when_fail'];
    _notifyWhenAchieve = json['notify_when_achieve'];
    _notified = json['notified'];
    _addedFrom = json['added_from'];
    _type = json['type'];
    _staffFirstname = json['staff_firstname'];
    _staffLastname = json['staff_lastname'];
  }

  String? _id;
  String? _subject;
  String? _description;
  String? _startDate;
  String? _endDate;
  String? _goalType;
  String? _achievement;
  String? _staffId;
  String? _contractType;
  String? _notifyWhenFail;
  String? _notifyWhenAchieve;
  String? _notified;
  String? _addedFrom;
  String? _type;
  String? _staffFirstname;
  String? _staffLastname;

  String? get id => _id;
  String? get subject => _subject;
  String? get description => _description;
  String? get startDate => _startDate;
  String? get endDate => _endDate;
  String? get goalType => _goalType;
  String? get achievement => _achievement;
  String? get staffId => _staffId;
  String? get contractType => _contractType;
  String? get notifyWhenFail => _notifyWhenFail;
  String? get notifyWhenAchieve => _notifyWhenAchieve;
  String? get notified => _notified;
  String? get addedFrom => _addedFrom;
  String? get type => _type;
  String? get staffFirstname => _staffFirstname;
  String? get staffLastname => _staffLastname;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['subject'] = _subject;
    map['description'] = _description;
    map['start_date'] = _startDate;
    map['end_date'] = _endDate;
    map['goal_type'] = _goalType;
    map['achievement'] = _achievement;
    map['staff_id'] = _staffId;
    map['contract_type'] = _contractType;
    map['notify_when_fail'] = _notifyWhenFail;
    map['notify_when_achieve'] = _notifyWhenAchieve;
    map['notified'] = _notified;
    map['added_from'] = _addedFrom;
    map['type'] = _type;
    map['staff_firstname'] = _staffFirstname;
    map['staff_lastname'] = _staffLastname;
    return map;
  }
}

class Overview {
  Overview({
    String? perfexLogo,
    String? perfexLogoDark,
    String? totalInvoices,
    String? invoicesAwaitingPaymentTotal,
    String? invoicesAwaitingPaymentPercent,
    String? totalLeads,
    String? leadsConvertedTotal,
    String? leadsConvertedPercent,
    String? totalProjects,
    String? projectsInProgressTotal,
    String? inProgressProjectsPercent,
    String? totalTasks,
    String? notFinishedTasksTotal,
    String? notFinishedTasksPercent,
  }) {
    _perfexLogo = perfexLogo;
    _perfexLogoDark = perfexLogoDark;
    _totalInvoices = totalInvoices;
    _invoicesAwaitingPaymentTotal = invoicesAwaitingPaymentTotal;
    _invoicesAwaitingPaymentPercent = invoicesAwaitingPaymentPercent;
    _totalLeads = totalLeads;
    _leadsConvertedTotal = leadsConvertedTotal;
    _leadsConvertedPercent = leadsConvertedPercent;
    _totalProjects = totalProjects;
    _projectsInProgressTotal = projectsInProgressTotal;
    _inProgressProjectsPercent = inProgressProjectsPercent;
    _totalTasks = totalTasks;
    _notFinishedTasksTotal = notFinishedTasksTotal;
    _notFinishedTasksPercent = notFinishedTasksPercent;
  }

  Overview.fromJson(dynamic json) {
    _perfexLogo = json['perfex_logo'];
    _perfexLogoDark = json['perfex_logo_dark'];
    _totalInvoices = json['total_invoices'];
    _invoicesAwaitingPaymentTotal = json['invoices_awaiting_payment_total'];
    _invoicesAwaitingPaymentPercent = json['invoices_awaiting_payment_percent'];
    _totalLeads = json['total_leads'];
    _leadsConvertedTotal = json['leads_converted_total'];
    _leadsConvertedPercent = json['leads_converted_percent'];
    _totalProjects = json['total_projects'];
    _projectsInProgressTotal = json['projects_in_progress_total'];
    _inProgressProjectsPercent = json['projects_in_progress_percent'];
    _totalTasks = json['total_tasks'];
    _notFinishedTasksTotal = json['tasks_not_finished_total'];
    _notFinishedTasksPercent = json['tasks_not_finished_percent'];
  }
  String? _perfexLogo;
  String? _perfexLogoDark;
  String? _totalInvoices;
  String? _invoicesAwaitingPaymentTotal;
  String? _invoicesAwaitingPaymentPercent;
  String? _totalLeads;
  String? _leadsConvertedTotal;
  String? _leadsConvertedPercent;
  String? _totalProjects;
  String? _projectsInProgressTotal;
  String? _inProgressProjectsPercent;
  String? _totalTasks;
  String? _notFinishedTasksTotal;
  String? _notFinishedTasksPercent;

  String? get perfexLogo => _perfexLogo;
  String? get perfexLogoDark => _perfexLogoDark;
  String? get totalInvoices => _totalInvoices;
  String? get invoicesAwaitingPaymentTotal => _invoicesAwaitingPaymentTotal;
  String? get invoicesAwaitingPaymentPercent => _invoicesAwaitingPaymentPercent;
  String? get totalLeads => _totalLeads;
  String? get leadsConvertedTotal => _leadsConvertedTotal;
  String? get leadsConvertedPercent => _leadsConvertedPercent;
  String? get totalProjects => _totalProjects;
  String? get projectsInProgressTotal => _projectsInProgressTotal;
  String? get inProgressProjectsPercent => _inProgressProjectsPercent;
  String? get totalTasks => _totalTasks;
  String? get notFinishedTasksTotal => _notFinishedTasksTotal;
  String? get notFinishedTasksPercent => _notFinishedTasksPercent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['perfex_logo'] = _perfexLogo;
    map['perfex_logo_dark'] = _perfexLogoDark;
    map['total_invoices'] = _totalInvoices;
    map['invoices_awaiting_payment_total'] = _invoicesAwaitingPaymentTotal;
    map['invoices_awaiting_payment_percent'] = _invoicesAwaitingPaymentPercent;
    map['total_leads'] = _totalLeads;
    map['leads_converted_total'] = _leadsConvertedTotal;
    map['leads_converted_percent'] = _leadsConvertedPercent;
    map['total_projects'] = _totalProjects;
    map['projects_in_progress_total'] = _projectsInProgressTotal;
    map['projects_in_progress_percent'] = _inProgressProjectsPercent;
    map['total_tasks'] = _totalTasks;
    map['tasks_not_finished_total'] = _notFinishedTasksTotal;
    map['tasks_not_finished_percent'] = _notFinishedTasksPercent;
    return map;
  }
}

class Data {
  Data({
    List<DataField>? invoices,
    List<DataField>? estimates,
    List<DataField>? proposals,
    List<DataField>? projects,
    List<DataField>? tasks,
    List<DataField>? leads,
    List<DataField>? tickets,
    CustomerSummery? customers,
  }) {
    _invoices = invoices;
    _estimates = estimates;
    _proposals = proposals;
    _projects = projects;
    _tasks = tasks;
    _leads = leads;
    _tickets = tickets;
    _customers = customers;
  }

  Data.fromJson(dynamic json) {
    if (json['invoices'] != null) {
      _invoices = [];
      json['invoices'].forEach((v) {
        _invoices?.add(DataField.fromJson(v));
      });
    }
    if (json['estimates'] != null) {
      _estimates = [];
      json['estimates'].forEach((v) {
        _estimates?.add(DataField.fromJson(v));
      });
    }
    if (json['proposals'] != null) {
      _proposals = [];
      json['proposals'].forEach((v) {
        _proposals?.add(DataField.fromJson(v));
      });
    }
    if (json['projects'] != null) {
      _projects = [];
      json['projects'].forEach((v) {
        _projects?.add(DataField.fromJson(v));
      });
    }
    if (json['tasks'] != null) {
      _tasks = [];
      json['tasks'].forEach((v) {
        _tasks?.add(DataField.fromJson(v));
      });
    }
    if (json['leads'] != null) {
      _leads = [];
      json['leads'].forEach((v) {
        _leads?.add(DataField.fromJson(v));
      });
    }
    if (json['tickets'] != null) {
      _tickets = [];
      json['tickets'].forEach((v) {
        _tickets?.add(DataField.fromJson(v));
      });
    }
    _customers = json['customers'] != null
        ? CustomerSummery.fromJson(json['customers'])
        : null;
  }

  List<DataField>? _invoices;
  List<DataField>? _estimates;
  List<DataField>? _proposals;
  List<DataField>? _projects;
  List<DataField>? _tasks;
  List<DataField>? _leads;
  List<DataField>? _tickets;
  CustomerSummery? _customers;

  List<DataField>? get invoices => _invoices;
  List<DataField>? get estimates => _estimates;
  List<DataField>? get proposals => _proposals;
  List<DataField>? get projects => _projects;
  List<DataField>? get tasks => _tasks;
  List<DataField>? get leads => _leads;
  List<DataField>? get tickets => _tickets;
  CustomerSummery? get customers => _customers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_invoices != null) {
      map['invoices'] = _invoices?.map((v) => v.toJson()).toList();
    }
    if (_estimates != null) {
      map['estimates'] = _estimates?.map((v) => v.toJson()).toList();
    }
    if (_proposals != null) {
      map['proposals'] = _proposals?.map((v) => v.toJson()).toList();
    }
    if (_projects != null) {
      map['projects'] = _projects?.map((v) => v.toJson()).toList();
    }
    if (_tasks != null) {
      map['tasks'] = _tasks?.map((v) => v.toJson()).toList();
    }
    if (_leads != null) {
      map['leads'] = _leads?.map((v) => v.toJson()).toList();
    }
    if (_tickets != null) {
      map['tickets'] = _tickets?.map((v) => v.toJson()).toList();
    }
    if (_customers != null) {
      map['customers'] = _customers?.toJson();
    }
    return map;
  }
}

class Staff {
  Staff({
    String? staffId,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImage,
  }) {
    _staffId = staffId;
    _email = email;
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    _profileImage = profileImage;
  }

  Staff.fromJson(dynamic json) {
    _staffId = json['staffid'];
    _email = json['email'];
    _firstName = json['firstname'];
    _lastName = json['lastname'];
    _phoneNumber = json['phonenumber'];
    _profileImage = json['profile_image'];
  }
  String? _staffId;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _profileImage;

  String? get staffId => _staffId;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get phoneNumber => _phoneNumber;
  String? get profileImage => _profileImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['staffId'] = _staffId;
    map['email'] = _email;
    map['firstname'] = _firstName;
    map['lastname'] = _lastName;
    map['phonenumber'] = _phoneNumber;
    map['profile_image'] = _profileImage;
    return map;
  }

  String get formattedProfileImage {
    if (_profileImage == null || _profileImage!.isEmpty) {
      return '';
    }
    if (_profileImage!.startsWith('http')) {
      return _profileImage!;
    }
    if (_profileImage!.contains('uploads/')) {
      return '${UrlContainer.domainUrl}/$_profileImage';
    }
    return '${UrlContainer.domainUrl}/uploads/staff_profile_images/$_staffId/$_profileImage';
  }
}

class MenuItems {
  MenuItems({
    bool? customers,
    bool? proposals,
    bool? estimates,
    bool? invoices,
    bool? payments,
    bool? creditNotes,
    bool? items,
    bool? subscriptions,
    bool? expenses,
    bool? contracts,
    bool? projects,
    bool? tasks,
    bool? tickets,
    bool? leads,
    bool? staff,
  }) {
    _customers = customers;
    _proposals = proposals;
    _estimates = estimates;
    _invoices = invoices;
    _payments = payments;
    _creditNotes = creditNotes;
    _items = items;
    _subscriptions = subscriptions;
    _expenses = expenses;
    _contracts = contracts;
    _projects = projects;
    _tasks = tasks;
    _tickets = tickets;
    _leads = leads;
    _staff = staff;
  }

  MenuItems.fromJson(dynamic json) {
    _customers = json['customers'];
    _proposals = json['proposals'];
    _estimates = json['estimates'];
    _invoices = json['invoices'];
    _payments = json['payments'];
    _creditNotes = json['credit_notes'];
    _items = json['items'];
    _subscriptions = json['subscriptions'];
    _expenses = json['expenses'];
    _contracts = json['contracts'];
    _projects = json['projects'];
    _tasks = json['tasks'];
    _tickets = json['tickets'];
    _leads = json['leads'];
    _staff = json['staff'];
  }
  bool? _customers;
  bool? _proposals;
  bool? _estimates;
  bool? _invoices;
  bool? _payments;
  bool? _creditNotes;
  bool? _items;
  bool? _subscriptions;
  bool? _expenses;
  bool? _contracts;
  bool? _projects;
  bool? _tasks;
  bool? _tickets;
  bool? _leads;
  bool? _staff;

  bool? get customers => _customers;
  bool? get proposals => _proposals;
  bool? get estimates => _estimates;
  bool? get invoices => _invoices;
  bool? get payments => _payments;
  bool? get creditNotes => _creditNotes;
  bool? get items => _items;
  bool? get subscriptions => _subscriptions;
  bool? get expenses => _expenses;
  bool? get contracts => _contracts;
  bool? get projects => _projects;
  bool? get tasks => _tasks;
  bool? get tickets => _tickets;
  bool? get leads => _leads;
  bool? get staff => _staff;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customers'] = _customers;
    map['proposals'] = _proposals;
    map['estimates'] = _estimates;
    map['invoices'] = _invoices;
    map['payments'] = _payments;
    map['credit_notes'] = _creditNotes;
    map['items'] = _items;
    map['subscriptions'] = _subscriptions;
    map['expenses'] = _expenses;
    map['contracts'] = _contracts;
    map['projects'] = _projects;
    map['tasks'] = _tasks;
    map['tickets'] = _tickets;
    map['leads'] = _leads;
    map['staff'] = _staff;
    return map;
  }
}

class DataField {
  DataField({
    String? status,
    String? total,
    String? percent,
  }) {
    _status = status;
    _total = total;
    _percent = percent;
  }

  DataField.fromJson(dynamic json) {
    _status = json['status'];
    _total = json['total'];
    _percent = json['percent'];
  }

  String? _status;
  String? _total;
  String? _percent;

  String? get status => _status;
  String? get total => _total;
  String? get percent => _percent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['total'] = _total;
    map['percent'] = _percent;
    return map;
  }
}

class CustomerSummery {
  CustomerSummery({
    String? customersTotal,
    String? customersActive,
    String? customersInactive,
    String? contactsActive,
    String? contactsInactive,
    String? contactsLastLogin,
  }) {
    _customersTotal = customersTotal;
    _customersActive = customersActive;
    _customersInactive = customersInactive;
    _contactsActive = contactsActive;
    _contactsInactive = contactsInactive;
    _contactsLastLogin = contactsLastLogin;
  }

  CustomerSummery.fromJson(dynamic json) {
    _customersTotal = json['customers_total'];
    _customersActive = json['customers_active'];
    _customersInactive = json['customers_inactive'];
    _contactsActive = json['contacts_active'];
    _contactsInactive = json['contacts_inactive'];
    _contactsLastLogin = json['contacts_last_login'];
  }
  String? _userid;
  String? _customersTotal;
  String? _customersActive;
  String? _customersInactive;
  String? _contactsActive;
  String? _contactsInactive;
  String? _contactsLastLogin;

  String? get userid => _userid;
  String? get customersTotal => _customersTotal;
  String? get customersActive => _customersActive;
  String? get customersInactive => _customersInactive;
  String? get contactsActive => _contactsActive;
  String? get contactsInactive => _contactsInactive;
  String? get contactsLastLogin => _contactsLastLogin;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userid'] = _userid;
    map['customers_total'] = _customersTotal;
    map['customers_active'] = _customersActive;
    map['customers_inactive'] = _customersInactive;
    map['contacts_active'] = _contactsActive;
    map['contacts_inactive'] = _contactsInactive;
    map['contacts_last_login'] = _contactsLastLogin;
    return map;
  }
}

class LeadTaskItem {
  String? id;
  String? hash;
  String? name;
  String? subject;
  String? title;
  String? company;
  String? companyIndustry;
  String? description;
  String? country;
  String? assigned;
  String? status; // Lead status ID

  LeadTaskItem({
    this.id,
    this.hash,
    this.name,
    this.subject,
    this.title,
    this.company,
    this.companyIndustry,
    this.description,
    this.country,
    this.assigned,
    this.status,
  });

  LeadTaskItem.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    hash = json['hash'];
    name = json['name'];
    subject = json['subject'];
    title = json['title'];
    company = json['company'];
    companyIndustry = json['company_industry'];
    description = json['description'];
    country = json['country'];
    assigned = json['assigned']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['hash'] = hash;
    data['name'] = name;
    data['subject'] = subject;
    data['title'] = title;
    data['company'] = company;
    data['company_industry'] = companyIndustry;
    data['description'] = description;
    data['country'] = country;
    data['status'] = status;
    return data;
  }
}
