import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/features/goal/controller/goal_controller.dart';
import 'package:flutex_admin/features/staff/repo/staff_repo.dart';
import 'package:flutex_admin/features/goal/repo/goal_repo.dart';
import 'package:flutex_admin/features/goal/view/staff_goals_screen.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(StaffRepo(apiClient: Get.find()));
    Get.put(GoalRepo(apiClient: Get.find()));
    final controller = Get.put(GoalController(staffRepo: Get.find(), goalRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.staffsModel.data == null || controller.staffsModel.data!.isEmpty) {
        controller.loadGoals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Goals", 
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.find<GoalController>().clearData();
          Get.toNamed(RouteHelper.addGoalScreen);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<GoalController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const CustomLoader();
          }
          if (controller.staffsModel.data == null || controller.staffsModel.data!.isEmpty) {
             return Center(child: Text("No staff found", style: regularDefault));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(Dimensions.space15),
            itemCount: controller.staffsModel.data!.length,
            itemBuilder: (context, index) {
              final staff = controller.staffsModel.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: (){
                     Get.to(() => StaffGoalsScreen(staffId: staff.id!, staffName: "${staff.firstName} ${staff.lastName}"));
                  },
                  contentPadding: const EdgeInsets.all(10),
                  title: Text("${staff.firstName} ${staff.lastName}", style: mediumDefault),
                  subtitle: Text(staff.email ?? '', style: lightSmall),
                  leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      child: CircleImageWidget(
                        imagePath: staff.profileImage ?? '',
                        isAsset: false,
                        isProfile: true,
                        width: 50,
                        height: 50,
                      )
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:", style: regularSmall.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: regularSmall)),
        ],
      ),
    );
  }
}
