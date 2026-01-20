import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_stats_model.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/route/route.dart'; // Import for navigation

class LeadsTasksCard extends StatefulWidget {
  final LeadsTasksSummary summary;
  const LeadsTasksCard({super.key, required this.summary});

  @override
  State<LeadsTasksCard> createState() => _LeadsTasksCardState();
}

class _LeadsTasksCardState extends State<LeadsTasksCard> {
  bool isToday = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leads & Tasks', style: regularLarge.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _buildTab('Today', true),
                    const SizedBox(width: 8),
                    _buildTab('Pending', false),
                  ],
                )
              ],
            ),
            const SizedBox(height: Dimensions.space20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    isToday ? 'Today Leads' : 'Pending Leads', // Dynamic label
                    isToday ? widget.summary.todayLeads : widget.summary.pendingLeads,
                    Colors.blue,
                    () => Get.toNamed(RouteHelper.leadScreen), // Navigation
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    isToday ? 'Today Tasks' : 'Pending Tasks', // Dynamic label
                    isToday ? widget.summary.todayTasks : widget.summary.pendingTasks,
                    Colors.orange,
                    () => Get.toNamed(RouteHelper.taskScreen), // Navigation
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool today) {
    bool selected = isToday == today;
    return InkWell(
      onTap: () {
        setState(() {
          isToday = today;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ColorResources.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: regularSmall.copyWith(
            color: selected ? Colors.white : Colors.black,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, int count, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: boldExtraLarge.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: regularSmall.copyWith(color: Colors.grey[700]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
