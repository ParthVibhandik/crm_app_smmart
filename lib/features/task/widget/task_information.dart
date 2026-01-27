import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/model/task_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';

class TaskInformation extends StatelessWidget {
  const TaskInformation({
    super.key,
    required this.taskModel,
  });
  final TaskDetails taskModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.space10),
      child: Column(
        children: [
          Container(
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taskModel.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            taskModel.projectData?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: lightSmall.copyWith(
                                color: ColorResources.blueGreyColor),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            Converter.taskPriorityString(
                                taskModel.priority ?? ''),
                            style: regularDefault.copyWith(
                              color: ColorResources.taskStatusColor(
                                  taskModel.priority ?? ''),
                            )),
                        Text(
                          taskModel.relType?.capitalizeFirst ?? '-',
                          style: lightSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const CustomDivider(space: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetBuilder<TaskController>(builder: (controller) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border:
                              Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: taskModel.status ?? '1',
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: controller.taskStatus.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: regularDefault.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null &&
                                  newValue != taskModel.status) {
                                controller.changeTaskStatus(
                                    taskModel.id!, newValue);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                    TextIcon(
                      text: DateConverter.formatValidityDate(
                          taskModel.dateAdded ?? ''),
                      icon: Icons.calendar_month,
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Container(
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
                Text(LocalStrings.description.tr, style: lightDefault),
                Text(Converter.parseHtmlString(taskModel.description ?? '-')),
                const CustomDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.hourlyRate.tr, style: lightDefault),
                    Text(LocalStrings.billable.tr, style: lightDefault),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(taskModel.hourlyRate ?? ''),
                    Text(taskModel.billable == '1'
                        ? LocalStrings.billable.tr
                        : LocalStrings.notBillable.tr),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Container(
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocalStrings.checklistItems.tr),
                  ],
                ),
                const CustomDivider(space: Dimensions.space10),
                (taskModel.checklistItems?.isNotEmpty ?? false)
                    ? ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final checklistItem =
                              taskModel.checklistItems![index];
                          return CheckboxListTile(
                            title: Text(
                              checklistItem.description ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            value: checklistItem.finished == '1',
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: ColorResources.secondaryColor,
                            checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            onChanged: (bool? value) {},
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: Dimensions.space10),
                        itemCount: taskModel.checklistItems!.length)
                    : Text(LocalStrings.checklistNotFound.tr,
                        textAlign: TextAlign.center, style: lightSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
