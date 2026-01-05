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
          floatingActionButton: AnimatedSlide(
            offset: controller.showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: controller.showFab ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: () => Get.toNamed(RouteHelper.addTaskScreen),
                backgroundColor: ColorResources.secondaryColor,
                child: const Icon(Icons.add, color: Colors.white),
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
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                       SliverAppBar(
                        pinned: true,
                        floating: true,
                        snap: true,
                        backgroundColor: ColorResources.primaryColor,
                        expandedHeight: 120.0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Get.back(),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            LocalStrings.tasks.tr,
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ColorResources.primaryColor,
                                  ColorResources.secondaryColor.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => controller.changeSearchIcon(),
                          ),
                        ],
                        bottom: controller.isSearch
                            ? PreferredSize(
                                preferredSize: const Size.fromHeight(60),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  color: Colors.white,
                                  child: SearchField(
                                    title: LocalStrings.taskDetails.tr,
                                    searchController: controller.searchController,
                                    onTap: () => controller.searchTask(),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      
                      if (controller.tasksModel.overview != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 160,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller.tasksModel.overview![index].total.toString(),
                                           style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                             color: ColorResources.taskStatusColor(controller.tasksModel.overview![index].status?.tr ?? ''),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          controller.tasksModel.overview![index].status?.tr ?? '',
                                          style: const TextStyle(fontSize: 14, color: ColorResources.hintColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemCount: controller.tasksModel.overview!.length,
                              ),
                            ),
                          ),
                        ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocalStrings.tasks.tr,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => CustomBottomSheet(child: TaskFilterBottomSheet()).customBottomSheet(context),
                                    icon: const Icon(Icons.filter_alt_outlined),
                                    color: ColorResources.primaryColor,
                                  ),
                                  IconButton(
                                    onPressed: () => CustomBottomSheet(child: TaskSortBottomSheet()).customBottomSheet(context),
                                    icon: const Icon(Icons.sort),
                                    color: ColorResources.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      controller.tasks.isNotEmpty
                          ? SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    bool isLastItem = index == controller.tasks.length - 1;
                                    if (isLastItem && controller.hasMoreData) {
                                      return Column(
                                        children: [
                                          TaskCard(task: controller.tasks[index]),
                                          const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        ],
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: TaskCard(task: controller.tasks[index]),
                                    );
                                  },
                                  childCount: controller.tasks.length,
                                ),
                              ),
                            )
                          : const SliverToBoxAdapter(child: NoDataWidget()),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
