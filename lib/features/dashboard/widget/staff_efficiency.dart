import 'package:flutex_admin/common/components/card/glass_card.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';

class StaffEfficiencyWidget extends StatelessWidget {
  const StaffEfficiencyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Efficiency Stats',
            style: semiBoldLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildEfficiencyRow('Tasks Completed', 0.85, Colors.greenAccent),
          const SizedBox(height: 15),
          _buildEfficiencyRow('Lead Conversion', 0.65, Colors.orangeAccent),
          const SizedBox(height: 15),
          _buildEfficiencyRow('Project On-time', 0.92, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildEfficiencyRow(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: regularDefault.copyWith(color: Colors.white70), overflow: TextOverflow.ellipsis)),
            Text('${(percent * 100).toInt()}%', style: semiBoldDefault.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
