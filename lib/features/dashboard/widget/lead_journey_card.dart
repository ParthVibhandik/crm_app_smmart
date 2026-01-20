import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_stats_model.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/route/route.dart';

class LeadJourneyCard extends StatelessWidget {
  final List<LeadJourneyStep> steps;
  const LeadJourneyCard({super.key, required this.steps});

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
             Text('Lead Statistics', style: regularLarge.copyWith(fontWeight: FontWeight.bold)),
             const SizedBox(height: Dimensions.space15),
             Wrap(
               spacing: 12,
               runSpacing: 12,
               children: steps.map((step) => _buildStatusItem(context, step)).toList(),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, LeadJourneyStep step) {
    // Assign colors based on label logic or random if generic
    Color color = _getColorForStatus(step.label);
    
    return InkWell(
      onTap: () {
        // Navigate to leads screen - passing status label as argument or filter
        // Currently just navigating as requested
        Get.toNamed(RouteHelper.leadScreen, arguments: {'status': step.label});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 35, // Approx half width minus padding
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
              style: regularDefault.copyWith(color: Colors.black87, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
