import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_stats_model.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';

class LeadJourneyCard extends StatelessWidget {
  final DashboardController controller;
  const LeadJourneyCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lead Statistics',
                    style: regularLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: Dimensions.space10),

                // Scrollable Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab('My', 'my'),
                      const SizedBox(width: 8),
                      _buildTab('All Team', 'all_team'),

                      // Dynamic Subordinate Tabs
                      if (controller.subordinateNames.isNotEmpty)
                        ...controller.subordinateNames.map((name) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildTab(
                                name, name), // name is both label and key
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.newStats.leadJourney
                  .map((step) => _buildStatusItem(context, step))
                  .toList(),
            ),
            if (controller.newStats.leadJourney.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                    child: Text(LocalStrings.noDataFound.tr,
                        style: regularDefault)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, String tabKey) {
    bool isSelected = controller.selectedLeadStatsTab == tabKey;
    return InkWell(
      onTap: () {
        controller.changeLeadStatsTab(tabKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorResources.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: regularDefault.copyWith(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, LeadJourneyStep step) {
    // Assign colors based on label logic or random if generic
    Color color = _getColorForStatus(step.label);

    return InkWell(
      onTap: () {
        // Get leads for this status and show modal
        List<LeadTaskItem> leads = controller.getLeadsByStatus(step.label);
        _showLeadsModal(context, step.label, leads, color);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) -
            35, // Approx half width minus padding
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('${step.count}', style: boldExtraLarge.copyWith(color: color)),
            const SizedBox(height: 5),
            Text(
              step.label,
              textAlign: TextAlign.center,
              style: regularDefault.copyWith(
                  color: Colors.black87, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showLeadsModal(BuildContext context, String statusLabel,
      List<LeadTaskItem> leads, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusLabel,
                      style: regularExtraLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 5),
              Text(
                '${leads.length} lead${leads.length != 1 ? 's' : ''}',
                style: regularDefault.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15),
              // Leads List
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.space20),
                          child: Text(
                            'No leads found',
                            style: regularDefault.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          return _buildLeadItem(context, leads[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeadItem(BuildContext context, LeadTaskItem lead) {
    return InkWell(
      onTap: () {
        // Close modal and navigate to lead details
        Navigator.of(context).pop();
        if (lead.id != null) {
          Get.toNamed(RouteHelper.leadDetailsScreen, arguments: lead.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lead.name ?? 'No Name',
                    style: regularDefault.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            if (lead.title != null && lead.title!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                lead.title!,
                style: regularSmall.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
            if (lead.company != null && lead.company!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lead.company!,
                      style: regularSmall.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
            if (lead.description != null && lead.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                lead.description!,
                style: regularSmall.copyWith(color: Colors.grey[500]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorForStatus(String label) {
    String lower = label.toLowerCase();
    if (lower.contains('hot')) return Colors.red;
    if (lower.contains('warm')) return Colors.orange;
    if (lower.contains('interested')) return Colors.purple;
    if (lower.contains('reachable')) return Colors.grey;
    if (lower.contains('follow')) return Colors.blue;
    return Colors.teal;
  }
}
