import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/goal/controller/goal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';

class StaffGoalsScreen extends StatefulWidget {
  final String staffId;
  final String staffName;
  const StaffGoalsScreen({super.key, required this.staffId, required this.staffName});

  @override
  State<StaffGoalsScreen> createState() => _StaffGoalsScreenState();
}

class _StaffGoalsScreenState extends State<StaffGoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<GoalController>().loadStaffGoals(widget.staffId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "${widget.staffName}'s Goals",
      ),
      body: GetBuilder<GoalController>(
        builder: (controller) {

          bool isLoading = controller.staffLoadingMap[widget.staffId] == true;
          if (isLoading) {
            return const CustomLoader();
          }
          final goals = controller.staffGoalsMap[widget.staffId];
           if (goals == null || goals.isEmpty) {
             return Center(child: Text("No goals found for this staff member.", style: regularDefault));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(Dimensions.space15),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: Dimensions.space15),
                padding: const EdgeInsets.all(Dimensions.space15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(Dimensions.cardRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            goal.subject ?? "No Subject",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorResources.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            controller.goalTypes[goal.goalType] ?? goal.goalType ?? 'N/A',
                            style: regularSmall.copyWith(color: ColorResources.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.space5),
                    Text(
                       goal.typeValue ?? 'Value',
                       style: lightSmall.copyWith(color: ColorResources.blueGreyColor),
                    ),
                    const CustomDivider(space: Dimensions.space15),
                    
                    if (goal.description != null && goal.description!.isNotEmpty) ...[
                      Text("Description", style: lightDefault),
                      const SizedBox(height: Dimensions.space5),
                      Text(Converter.parseHtmlString(goal.description!)),
                      const CustomDivider(space: Dimensions.space15),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(context, "Start Date", goal.startDate ?? '-'),
                        ),
                        Expanded(
                          child: _buildInfoItem(context, "End Date", goal.endDate ?? '-'),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.space15),
                    
                    Row(
                      children: [
                         Expanded(
                          child: _buildInfoItem(context, "Achievement", goal.achievement ?? '-', isHighlight: true),
                        ),
                        Expanded(
                          child: _buildInfoItem(context, "Recurring", goal.recurring ?? 'No'),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: lightSmall),
        const SizedBox(height: 2),
        Text(
          value, 
          style: regularDefault.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? Colors.green : Theme.of(context).textTheme.bodyMedium?.color
          )
        ),
      ],
    );
  }
}
