import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';

class GoalsCard extends StatefulWidget {
  final DashboardController controller;
  const GoalsCard({super.key, required this.controller});

  @override
  State<GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends State<GoalsCard> {
  bool _isExpanded = false;
  String _lastFilterKey = '';

  @override
  Widget build(BuildContext context) {
    // Generate a unique key based on current filter states
    String currentFilterKey =
        '${widget.controller.selectedGoalMainTab}_${widget.controller.selectedGoalSubTab}_${widget.controller.selectedGoalDateFilter}';

    // Reset expansion if filters have changed
    if (currentFilterKey != _lastFilterKey) {
      _isExpanded = false; // Reset to default view
      _lastFilterKey = currentFilterKey;
    }

    Goals? goals = widget.controller.homeModel.goals;
    if (goals == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("No goals configuration found."),
        ),
      );
    }

    // Use unified subordinates from controller (includes both goals and leads/tasks)
    List<DashboardSubordinate> unifiedSubs = widget.controller.unifiedSubordinates;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Goals',
                  style: regularLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterTab('All', 'all', widget.controller),
                      _buildFilterTab('MTD', 'mtd', widget.controller),
                      _buildFilterTab('YTD', 'ytd', widget.controller),
                      _buildFilterTab('Custom', 'custom', widget.controller),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space15),

            // Row 1: Horizontal Scrollable Tabs (My + Subordinates)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMainTabButton(
                      'My',
                      widget.controller.selectedGoalMainTab == 'my',
                      () => widget.controller.changeGoalMainTab('my')),
                  if (unifiedSubs.isNotEmpty)
                    ...unifiedSubs.map((sub) {
                      String name = sub.name;
                      bool isSelected =
                          widget.controller.selectedGoalMainTab == sub.id;
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _buildMainTabButton(name, isSelected,
                            () => widget.controller.changeGoalMainTab(sub.id)),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),

            // Row 3: Conditional Sub-tabs (Only for "My")
            if (widget.controller.selectedGoalMainTab == 'my') ...[
              Row(
                children: [
                  Expanded(
                    child: _buildSubTabButton(
                      'Assigned Goals',
                      widget.controller.selectedGoalSubTab == 'assigned',
                      () => widget.controller.changeGoalSubTab('assigned'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSubTabButton(
                      'Self Assigned Goals',
                      widget.controller.selectedGoalSubTab == 'self',
                      () => widget.controller.changeGoalSubTab('self'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],

            // Data Rendering
            _buildGoalsList(context, goals),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTabButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ColorResources.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: regularDefault.copyWith(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildSubTabButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorResources.primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? ColorResources.primaryColor
                  : (Colors.grey[300] ?? Colors.grey)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: regularDefault.copyWith(
              color: isSelected ? ColorResources.primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildFilterTab(
      String label, String value, DashboardController controller) {
    bool isSelected = controller.selectedGoalDateFilter == value;
    return InkWell(
      onTap: () {
        controller.changeGoalDateFilter(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 2)
                  ]
                : null),
      child: Text(
        label,
        style: regularSmall.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600]),
      ),
    ),
  );
}

  Widget _buildGoalsList(BuildContext context, Goals goals) {
    List<Goal> sourceGoals = [];

    // 1. Select Source
    if (widget.controller.selectedGoalMainTab == 'my') {
      if (widget.controller.selectedGoalSubTab == 'assigned') {
        sourceGoals = goals.assignedGoals ?? [];
      } else {
        sourceGoals = goals.selfGoals ?? [];
      }
    } else {
      // It's a specific subordinate
      String staffId = widget.controller.selectedGoalMainTab;
      sourceGoals = (goals.subordinatesGoals ?? [])
          .where((g) => g.staffId == staffId)
          .toList();
    }

    // 2. Apply Type Filter (MTD, YTD, Custom)
    List<Goal> displayGoals = _filterGoalsByType(sourceGoals, widget.controller);

    if (displayGoals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No goals found.", style: regularDefault),
        ),
      );
    }

    // Logic for truncation
    bool showViewMore = displayGoals.length > 5;
    List<Goal> visibleGoals =
        (_isExpanded || !showViewMore) ? displayGoals : displayGoals.take(5).toList();

    return Column(
      children: [
        ...visibleGoals.map((goal) => _buildGoalItem(context, goal)),
        if (showViewMore)
           Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isExpanded ? "View Less" : "View More",
                  style: regularDefault.copyWith(
                    color: ColorResources.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Goal> _filterGoalsByType(
      List<Goal> goals, DashboardController controller) {
    String filter = controller.selectedGoalDateFilter;
    if (filter == 'all') return goals;

    // Filter goals where type matches the selected filter (MTD, YTD, Custom)
    // Using case-insensitive comparison
    return goals.where((goal) {
      String type = (goal.type ?? '').toLowerCase();
      return type == filter.toLowerCase();
    }).toList();
  }

  Widget _buildGoalItem(BuildContext context, Goal goal) {
    Map<String, dynamic> statusInfo = _getGoalStatusInfo(goal);

    return InkWell(
      onTap: () => _showGoalDetailModal(context, goal),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.subject ?? 'No Subject',
                    style: regularDefault.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: (statusInfo['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    statusInfo['text'],
                    style: regularSmall.copyWith(color: statusInfo['color']),
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Text(
              goal.description != null && goal.description!.isNotEmpty
                  ? goal.description!
                  : '—',
              style: regularSmall.copyWith(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.startDate ?? '-'} to ${goal.endDate ?? '-'}',
                  style:
                      regularSmall.copyWith(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  'Target: ${goal.achievement ?? '0'}',
                  style: regularDefault.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.green),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showGoalDetailModal(BuildContext context, Goal goal) {
    Map<String, dynamic> statusInfo = _getGoalStatusInfo(goal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.subject ?? 'Goal Details',
                        style: regularExtraLarge.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: (statusInfo['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    statusInfo['text'],
                    style: regularDefault.copyWith(
                        color: statusInfo['color'],
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Start Date', goal.startDate ?? '-'),
                _buildDetailRow('End Date', goal.endDate ?? '-'),
                _buildDetailRow('Achievement', goal.achievement ?? '-'),
                _buildDetailRow('Goal Type', goal.goalType ?? '-'),
                _buildDetailRow('Type', goal.type ?? 'N/A'),
                _buildDetailRow('Contract Type', goal.contractType ?? '-'),
                _buildDetailRow('Staff ID', goal.staffId ?? '-'),
                _buildDetailRow('Staff Name',
                    '${goal.staffFirstname ?? ''} ${goal.staffLastname ?? ''}'),
                const SizedBox(height: 20),
                Text('Description:',
                    style:
                        regularDefault.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    goal.description != null && goal.description!.isNotEmpty
                        ? goal.description!
                        : 'No description provided.',
                    style: regularDefault.copyWith(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: regularDefault.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: regularDefault.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getGoalStatusInfo(Goal goal) {
    String text = goal.type ?? goal.goalType ?? 'Unknown';
    Color color = Colors.blue;
    return {'text': text, 'color': color};
  }
}
