import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_stats_model.dart';

class GoalsCard extends StatelessWidget {
  final List<GoalTarget> goals;
  const GoalsCard({super.key, required this.goals});

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
             Text('Goals', style: regularLarge.copyWith(fontWeight: FontWeight.bold)),
             const SizedBox(height: Dimensions.space15),
             if(goals.isEmpty) Text("No goals set", style: regularSmall),
             ...goals.map((g) => _buildGoalItem(context, g)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, GoalTarget goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.period, style: regularDefault.copyWith(fontWeight: FontWeight.w600)),
              Text('${goal.achieved.toInt()} / ${goal.target.toInt()}', style: regularSmall.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress > 1.0 ? 1.0 : goal.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getColor(goal.progress)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 2),
           Align(
             alignment: Alignment.centerRight,
             child: Text('Remaining: ${goal.remaining.toInt()}', style: regularSmall.copyWith(fontSize: 10, color: Colors.red)),
           )
        ],
      ),
    );
  }

  Color _getColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
