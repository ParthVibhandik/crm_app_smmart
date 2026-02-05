import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/goal/model/goal_detail_model.dart';
import 'package:flutex_admin/features/goal/view/add_goal_screen.dart';
import 'package:flutex_admin/features/goal/controller/goal_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:get/get.dart';

class GoalDetailsScreen extends StatelessWidget {
  final GoalDetailData goal;
  final Map<String, String> goalTypes;

  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.goalTypes,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'Goal Details',
            isShowActionBtn: true,
            actionWidget: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                 final controller = Get.find<GoalController>();
                 controller.setGoalForEdit(goal);
                 Get.to(() => const AddGoalScreen());
              },
            )),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).cardColor,
              child: TabBar(
                labelColor: ColorResources.primaryColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                indicatorColor: ColorResources.primaryColor,
                labelStyle: regularDefault.copyWith(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Achievement'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDetailsTab(context),
                  _buildAchievementTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if(goal.id != null) {
          await Get.find<GoalController>().refreshGoalDetails(goal.id!);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
            context,
            children: [
              _buildDetailRow(context, 'Subject', goal.subject ?? '-'),
              const SizedBox(height: Dimensions.space15),
              _buildDetailRow(context, 'Goal Type', goalTypes[goal.goalType] ?? goal.goalType ?? '-'),
              const SizedBox(height: Dimensions.space15),
              Row(
                children: [
                  Expanded(child: _buildDetailRow(context, 'Start Date', goal.startDate ?? '-')),
                  Expanded(child: _buildDetailRow(context, 'End Date', goal.endDate ?? '-')),
                ],
              ),
              const SizedBox(height: Dimensions.space15),
              Row(
                children: [
                  Expanded(child: _buildDetailRow(context, 'Target', goal.target ?? '0')),
                  Expanded(child: _buildDetailRow(context, 'Achievement', goal.achievement?.total?.toString() ?? '0')),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space15),
          if (goal.description != null && goal.description!.isNotEmpty)
            _buildSectionCard(
              context,
              children: [
                Text('Description', style: lightSmall),
                const SizedBox(height: Dimensions.space5),
                Text(Converter.parseHtmlString(goal.description!)),
              ],
            ),
        ],
      ),
    ),
  );
}

  Widget _buildAchievementTab(BuildContext context) {
    // Parse values safely
    double percentStrValue = double.tryParse(goal.achievement?.percent ?? '0') ?? 0.0;
    double percentValue = percentStrValue / 100;
    
    // Determine target and achievement
    // Note: 'target' is a string in API response "2000000"
    double targetAmount = double.tryParse(goal.target ?? '0') ?? 0.0;
    double achievementAmount = double.tryParse(goal.achievement?.total?.toString() ?? '0') ?? 0.0;
    
    double leftAmount = targetAmount - achievementAmount;
    if (leftAmount < 0) leftAmount = 0;

    return RefreshIndicator(
      onRefresh: () async {
         if(goal.id != null) {
            // We need to reload the details. 
            // Call controller method but we are inside a stateless widget.
            // We can call controller.loadGoalDetails(goal.id!) but that pushes a new screen currently.
            // Ideally we should reload this screen's data. 
            // For now, let's just trigger the load which updates the dialog/screen.
            // Better approach is to make this screen a GetBuilder or Obx if we want reactive updates on same screen.
            // But since loadGoalDetails pushes a new route, we might need a specific 'refreshGoalDetails' that just updates data?
            // Or simpler: just call loadGoalDetails(id) which will fetch and RE-NAVIGATE to this screen (replacing it or pushing on top).
            // To do it properly inline, we would need to change this to a GetView or use GetBuilder.
            // Given the constraints, calling loadGoalDetails again will "refresh" by showing the updated data in a new instance (simulating refresh).
            // OR better: use Get.find<GoalController>().loadGoalDetails(goal.id!) but we need to prevent stacking.
            
            // Let's use a cleaner approach:
            // The controller has the logic. 
            await Get.find<GoalController>().refreshGoalDetails(goal.id!);
         }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.space20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: Dimensions.space20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: percentValue,
                      strokeWidth: 20,
                      backgroundColor: ColorResources.colorGrey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getColorForPercent(percentValue)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${percentStrValue.toStringAsFixed(2)}%",
                        style: boldExtraLarge.copyWith(fontSize: 40, color: _getColorForPercent(percentValue)),
                      ),
                      Text(
                        "Completed",
                        style: lightDefault,
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space40),
              _buildSectionCard(
                context,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       _buildStatItem(context, 'Total Achievement', achievementAmount.toStringAsFixed(0)),
                       _buildStatItem(context, 'Target', targetAmount.toStringAsFixed(0)),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space20),
                   Center(child: _buildStatItem(context, 'Left To Achieve', leftAmount.toStringAsFixed(0), color: Colors.redAccent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getColorForPercent(double value) {
    if (value >= 1.0) return Colors.green;
    if (value >= 0.7) return Colors.lightGreen;
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatItem(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: boldLarge.copyWith(fontSize: 24, color: color ?? ColorResources.primaryColor)),
        const SizedBox(height: 5),
        Text(label, style: lightDefault),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: lightSmall),
        const SizedBox(height: 4),
        Text(value, style: regularDefault),
      ],
    );
  }
}
