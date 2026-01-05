import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
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
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutex_admin/features/project/widget/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    handleScroll();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  bool showFab = true;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  void handleScroll() async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showFab) setState(() => showFab = false);
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showFab) setState(() => showFab = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: AnimatedSlide(
            offset: showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: showFab ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: () => Get.toNamed(RouteHelper.addProjectScreen),
                backgroundColor: ColorResources.secondaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async {
                    await controller.initialData(shouldLoad: false);
                  },
                  child: CustomScrollView(
                    controller: scrollController,
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
                            LocalStrings.projects.tr,
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
                                    title: LocalStrings.projectDetails.tr,
                                    searchController: controller.searchController,
                                    onTap: () => controller.searchProject(),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      
                      if (controller.projectsModel.overview != null)
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
                                          controller.projectsModel.overview![index].total.toString(),
                                           style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: ColorResources.projectStatusColor(controller.projectsModel.overview![index].status!.tr),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          controller.projectsModel.overview![index].status!.tr,
                                          style: const TextStyle(fontSize: 14, color: ColorResources.hintColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemCount: controller.projectsModel.overview!.length,
                              ),
                            ),
                          ),
                        ),

                      controller.projectsModel.data?.isNotEmpty ?? false
                          ? SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ProjectCard(
                                        index: index,
                                        projectModel: controller.projectsModel,
                                      ),
                                    );
                                  },
                                  childCount: controller.projectsModel.data!.length,
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
