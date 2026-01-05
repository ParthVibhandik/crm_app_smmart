import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:flutex_admin/features/lead/widget/lead_sort_bottom_sheet.dart';
import 'package:flutex_admin/features/lead/widget/lead_filter_bottom_sheet.dart';
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
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/lead/widget/lead_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LeadRepo(apiClient: Get.find()));
    final controller = Get.put(LeadController(leadRepo: Get.find()));
    controller.isLoading = true;
    controller.handleScroll();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: AnimatedSlide(
            offset: controller.showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: controller.showFab ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: () => Get.toNamed(RouteHelper.addLeadScreen),
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
                    controller.initialData();
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
                            LocalStrings.leads.tr,
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
                            onPressed: () => Get.toNamed(RouteHelper.kanbanLeadScreen),
                            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () => controller.changeSearchIcon(),
                            icon: Icon(controller.isSearch ? Icons.clear : Icons.search, color: Colors.white),
                          ),
                        ],
                        bottom: controller.isSearch
                            ? PreferredSize(
                                preferredSize: const Size.fromHeight(60),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  color: Colors.white,
                                  child: SearchField(
                                    title: LocalStrings.leadDetails.tr,
                                    searchController: controller.searchController,
                                    onTap: () => controller.searchLead(),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      
                       SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                               InkWell(
                                onTap: () => CustomBottomSheet(
                                  child: LeadFilterBottomSheet(),
                                ).customBottomSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                       BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.filter_alt_outlined, size: 16, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 6),
                                      Text(LocalStrings.filter.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => CustomBottomSheet(
                                  child: LeadSortBottomSheet(),
                                ).customBottomSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                     boxShadow: [
                                       BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.sort, size: 16, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 6),
                                      Text(LocalStrings.sortBy.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      if (controller.leadsModel.overview != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return _buildOverviewCard(
                                    context,
                                    controller.leadsModel.overview![index].status!.tr,
                                    controller.leadsModel.overview![index].total.toString(),
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemCount: controller.leadsModel.overview!.length,
                              ),
                            ),
                          ),
                        ),

                      controller.leads.isNotEmpty
                          ? SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              sliver: Obx(
                                () => SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          children: [
                                            LeadCard(
                                              lead: controller.leads[index],
                                            ),
                                            if (index == controller.leads.length - 1 && controller.hasMoreData)
                                              const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: CustomLoader(isFullScreen: false, isPagination: true),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                    childCount: controller.leads.length,
                                  ),
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

  Widget _buildOverviewCard(BuildContext context, String title, String count) {
    return Container(
      width: 140,
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
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
             style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
