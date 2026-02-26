import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:flutex_admin/common/components/custom_fab.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/common/components/overview_card.dart';
import 'package:flutex_admin/common/components/search_field.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/task/widget/task_card.dart';
import 'package:flutex_admin/features/task/widget/task_filter_bottom_sheet.dart';
import 'package:flutex_admin/features/task/widget/task_sort_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TaskRepo(apiClient: Get.find()));
    final controller = Get.put(TaskController(taskRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    controller.handleScroll();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: LocalStrings.tasks.tr,
            isShowActionBtn: true,
            actionWidget: IconButton(
              onPressed: () => controller.changeSearchIcon(),
              icon: Icon(controller.isSearch ? Icons.clear : Icons.search),
            ),
          ),
          floatingActionButton: AnimatedSlide(
            offset: controller.showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: controller.showFab ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: CustomFAB(
                isShowIcon: true,
                isShowText: false,
                press: () {
                  Get.toNamed(RouteHelper.addTaskScreen);
                },
              ),
            ),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : RefreshIndicator(
                  color: ColorResources.primaryColor,
                  onRefresh: () async {
                    await controller.initialData();
                  },
                  child: Column(
                    children: [
                      Visibility(
                        visible: controller.isSearch,
                        child: SearchField(
                          title: LocalStrings.taskDetails.tr,
                          searchController: controller.searchController,
                          onTap: () => controller.searchTask(),
                        ),
                      ),
                      if (controller.tasksModel.overview != null)
                        ExpansionTile(
                          title: Row(
                            children: [
                              Container(
                                width: Dimensions.space3,
                                height: Dimensions.space15,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: Dimensions.space5),
                              Text(
                                LocalStrings.taskSummery.tr,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          shape: const Border(),
                          initiallyExpanded: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.space15,
                              ),
                              child: SizedBox(
                                height: 80,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return OverviewCard(
                                      name: controller.tasksModel
                                              .overview![index].status?.tr ??
                                          '',
                                      number: controller
                                          .tasksModel.overview![index].total
                                          .toString(),
                                      color: ColorResources.blueColor,
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: Dimensions.space5),
                                  itemCount:
                                      controller.tasksModel.overview!.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space15,
                          vertical: Dimensions.space10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocalStrings.tasks.tr,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Row(
                              spacing: Dimensions.space15,
                              children: [
                                InkWell(
                                  onTap: () => CustomBottomSheet(
                                    child: TaskFilterBottomSheet(),
                                  ).customBottomSheet(context),
                                  child: TextIcon(
                                    text: LocalStrings.filter.tr,
                                    icon: Icons.filter_alt,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => CustomBottomSheet(
                                    child: TaskSortBottomSheet(),
                                  ).customBottomSheet(context),
                                  child: TextIcon(
                                    text: LocalStrings.sortBy.tr,
                                    icon: Icons.sort,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      controller.tasksModel.subordinatesTasks != null &&
                              controller
                                  .tasksModel.subordinatesTasks!.isNotEmpty
                          ? Flexible(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(
                                    bottom: Dimensions.space20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (controller.tasksModel.selfTasks !=
                                            null &&
                                        controller.tasksModel.selfTasks!
                                            .isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 10, 15, 5),
                                        child: Text("Self Tasks",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                      ),
                                      ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions.space15),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: controller
                                            .tasksModel.selfTasks!.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                                height: Dimensions.space10),
                                        itemBuilder: (context, index) {
                                          return TaskCard(
                                              task: controller.tasksModel
                                                  .selfTasks![index]);
                                        },
                                      ),
                                      const SizedBox(
                                          height: Dimensions.space15),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 10, 15, 5),
                                      child: Text("Subordinates Tasks",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    ...controller
                                        .tasksModel.subordinatesTasks!.entries
                                        .map((entry) {
                                      return ExpansionTile(
                                        initiallyExpanded: false,
                                        title: Text(entry.key,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        children: [
                                          ListView.separated(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions.space15,
                                                vertical: 10),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: entry.value.length,
                                            separatorBuilder: (context,
                                                    index) =>
                                                const SizedBox(
                                                    height: Dimensions.space10),
                                            itemBuilder: (context, index) {
                                              return TaskCard(
                                                  task: entry.value[index]);
                                            },
                                          )
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            )
                          : controller.tasks.isNotEmpty
                              ? Flexible(
                                  child: Obx(
                                    () => ListView.separated(
                                      controller: controller.scrollController,
                                      padding: const EdgeInsets.fromLTRB(
                                        Dimensions.space15,
                                        0,
                                        Dimensions.space15,
                                        Dimensions.space15,
                                      ),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        bool isLastItem = index ==
                                            controller.tasks.length - 1;
                                        if (isLastItem &&
                                            controller.hasMoreData) {
                                          return Column(
                                            children: [
                                              TaskCard(
                                                task: controller.tasks[index],
                                              ),
                                              const SizedBox(
                                                height: Dimensions.space10,
                                              ),
                                              const CustomLoader(
                                                isFullScreen: false,
                                                isPagination: true,
                                              ),
                                            ],
                                          );
                                        }
                                        return TaskCard(
                                          task: controller.tasks[index],
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                        height: Dimensions.space10,
                                      ),
                                      itemCount: controller.tasks.length,
                                    ),
                                  ),
                                )
                              : NoDataWidget(
                                  text: controller.tasksModel.message ??
                                      LocalStrings.noDataFound),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
