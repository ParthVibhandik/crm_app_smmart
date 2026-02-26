import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_drop_down_text_field.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/goal/controller/goal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<GoalController>();
    if (controller.staffsModel.data == null ||
        controller.staffsModel.data!.isEmpty) {
      controller.loadGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
              title: controller.editingGoalId != null
                  ? "Update Goal"
                  : "Add Goal"),
          body: controller.isLoading
              ? const CustomLoader()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.space15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        labelText: "Subject",
                        controller: controller.subjectController,
                        hintText: "Enter subject",
                        onChanged: (val) {},
                      ),
                      const SizedBox(height: Dimensions.space15),
                      CustomDropDownTextField(
                        labelText: "Goal Type",
                        selectedValue: controller.selectedGoalType,
                        hintText: "Select Goal Type",
                        onChanged: (val) {
                          controller.selectedGoalType = val;
                          controller.update();
                        },
                        items: controller.goalTypes.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: regularDefault.copyWith(
                                    color: Colors.black)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      CustomDropDownTextField(
                        labelText: "Staff Member",
                        selectedValue: controller.selectedStaffId,
                        hintText: "Select Staff",
                        onChanged: (val) {
                          controller.selectedStaffId = val;
                          controller.update();
                        },
                        items: controller.staffsModel.data?.map((staff) {
                              return DropdownMenuItem(
                                value: staff.id,
                                child: Text(
                                    "${staff.firstName} ${staff.lastName}",
                                    style: regularDefault.copyWith(
                                        color: Colors.black)),
                              );
                            }).toList() ??
                            [],
                      ),
                      const SizedBox(height: Dimensions.space15),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  controller.startDateController.text =
                                      DateConverter.formatDate(pickedDate);
                                }
                              },
                              child: CustomTextField(
                                labelText: "Start Date",
                                controller: controller.startDateController,
                                hintText: "yyyy-MM-dd",
                                isEnable: false,
                                onChanged: (val) {},
                              ),
                            ),
                          ),
                          const SizedBox(width: Dimensions.space15),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  controller.endDateController.text =
                                      DateConverter.formatDate(pickedDate);
                                }
                              },
                              child: CustomTextField(
                                labelText: "End Date",
                                controller: controller.endDateController,
                                hintText: "yyyy-MM-dd",
                                isEnable: false,
                                onChanged: (val) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space15),
                      CustomDropDownTextField(
                        labelText: "Goal Duration",
                        selectedValue: controller.selectedPeriod,
                        hintText: "Select Duration",
                        onChanged: (val) {
                          controller.selectedPeriod = val;
                          controller.update();
                        },
                        items: controller.goalPeriods.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: regularDefault.copyWith(
                                    color: Colors.black)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      CustomTextField(
                        labelText: "Target Goal Amount",
                        controller: controller.achievementController,
                        hintText: "Enter target amount",
                        textInputType: TextInputType.number,
                        onChanged: (val) {},
                      ),
                      const SizedBox(height: Dimensions.space15),
                      CustomTextField(
                        labelText: "Description",
                        controller: controller.descriptionController,
                        hintText: "Enter description",
                        maxLines: 3,
                        onChanged: (val) {},
                      ),
                      const SizedBox(height: Dimensions.space25),
                      controller.isSubmitLoading
                          ? const CustomLoader()
                          : RoundedButton(
                              text: controller.editingGoalId != null
                                  ? "Update Goal"
                                  : "Save Goal",
                              press: () {
                                controller.createGoal();
                              },
                            )
                    ],
                  ),
                ),
        );
      },
    );
  }
}
