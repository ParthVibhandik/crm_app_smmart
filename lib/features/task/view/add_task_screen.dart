import 'package:async/async.dart';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/custom_date_form_field.dart';
import 'package:flutex_admin/common/components/custom_drop_down_button_with_text_field.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_drop_down_text_field.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_multi_drop_down_text_field.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/contract/model/contract_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/project/model/project_model.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final AsyncMemoizer<CustomersModel> customersMemoizer = AsyncMemoizer();
  final AsyncMemoizer<LeadsModel> leadsMemoizer = AsyncMemoizer();
  final AsyncMemoizer<ProjectsModel> projectsMemoizer = AsyncMemoizer();
  final AsyncMemoizer<InvoicesModel> invoicesMemoizer = AsyncMemoizer();
  final AsyncMemoizer<ProposalsModel> proposalsMemoizer = AsyncMemoizer();
  final AsyncMemoizer<ContractsModel> contractsMemoizer = AsyncMemoizer();
  final AsyncMemoizer<EstimatesModel> estimatesMemoizer = AsyncMemoizer();
  final AsyncMemoizer<StaffsModel> subordinatesMemoizer = AsyncMemoizer();

  @override
  void dispose() {
    Get.find<TaskController>().clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: LocalStrings.createNewTask.tr,
      ),
      body: GetBuilder<TaskController>(
        builder: (controller) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space15),
              child: Column(
                children: [
                  CustomTextField(
                    labelText: LocalStrings.subject.tr,
                    controller: controller.subjectController,
                    focusNode: controller.subjectFocusNode,
                    textInputType: TextInputType.text,
                    nextFocus: controller.assignedToFocusNode,
                    onChanged: (value) {
                      return;
                    },
                  ),
                  const SizedBox(height: Dimensions.space15),
                  CustomTextField(
                    labelText: LocalStrings.description.tr,
                    controller: controller.descriptionController,
                    focusNode: controller.descriptionFocusNode,
                    textInputType: TextInputType.text,
                    maxLines: 3,
                    onChanged: (value) {
                      return;
                    },
                  ),
                  const SizedBox(height: Dimensions.space15),
                  FutureBuilder(
                      future: subordinatesMemoizer
                          .runOnce(controller.loadSubordinates),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CustomLoader(isFullScreen: false);
                        } else if (snapshot.hasData &&
                            snapshot.data!.status == true &&
                            snapshot.data!.data != null &&
                            snapshot.data!.data!.isNotEmpty) {
                          return CustomMultiDropDownTextField(
                            hintText: LocalStrings.assignedTo.tr,
                            controller: controller.assignedToController,
                            onChanged: (selectedItems) {
                              controller.update();
                            },
                            items: snapshot.data!.data!
                                .map((value) {
                              return DropdownItem<String>(
                                label: "${value.firstName} ${value.lastName}",
                                value: value.id.toString(),
                              );
                            }).toList(),
                          );
                        } else {
                          return CustomDropDownWithTextField(
                              selectedValue: "No Subordinates Found",
                              list: ["No Subordinates Found"]);
                        }
                      }),
                  const SizedBox(height: Dimensions.space15),
                  CustomDropDownTextField(
                    hintText: LocalStrings.selectPriority.tr,
                    onChanged: (value) {
                      controller.taskPriorityController.text = value;
                    },
                    selectedValue: controller.taskPriorityController.text,
                    items: controller.taskPriority.entries
                        .map((MapEntry element) => DropdownMenuItem(
                              value: element.key,
                              child: Text(
                                element.value,
                                style: regularDefault.copyWith(
                                  color: ColorResources.taskPriorityColor(
                                      element.key ?? ''),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: Dimensions.space15),
                  CustomDropDownTextField(
                    hintText: "Status",
                    onChanged: (value) {
                      controller.taskStatusController.text = value;
                    },
                    selectedValue: controller.taskStatusController.text.isEmpty
                        ? '1'
                        : controller.taskStatusController.text,
                    items: controller.taskStatus.entries
                        .map((MapEntry element) => DropdownMenuItem(
                              value: element.key,
                              child: Text(
                                element.value,
                                style: regularDefault.copyWith(
                                    color: Colors.black),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: Dimensions.space15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDateFormField(
                          labelText: LocalStrings.startDate.tr,
                          onChanged: (DateTime? value) {
                            controller.startDateController.text =
                                DateConverter.formatDate(value!);
                          },
                        ),
                      ),
                      const SizedBox(width: Dimensions.space5),
                      Expanded(
                        child: CustomDateFormField(
                          labelText: LocalStrings.dueDate.tr,
                          onChanged: (DateTime? value) {
                            controller.dueDateController.text =
                                DateConverter.formatDate(value!);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
        child: GetBuilder<TaskController>(builder: (controller) {
          return controller.isSubmitLoading
              ? const RoundedLoadingBtn()
              : RoundedButton(
                  text: LocalStrings.submit.tr,
                  press: () {
                    controller.submitTask();
                  },
                );
        }),
      ),
    );
  }
}
