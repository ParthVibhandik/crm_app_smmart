import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_fab.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/common/components/search_field.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/customer/controller/customer_controller.dart';
import 'package:flutex_admin/features/customer/repo/customer_repo.dart';
import 'package:flutex_admin/features/customer/widget/customers_card.dart';
import 'package:flutex_admin/features/dashboard/widget/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CustomerRepo(apiClient: Get.find()));
    final controller = Get.put(CustomerController(customerRepo: Get.find()));
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
    return GetBuilder<CustomerController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: AnimatedSlide(
            offset: showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: showFab ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: () => Get.toNamed(RouteHelper.addCustomerScreen),
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
                            LocalStrings.customers.tr,
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
                              onPressed: () => controller.changeSearchIcon(),
                              icon: Icon(controller.isSearch ? Icons.clear : Icons.search, color: Colors.white)),
                        ],
                        bottom: controller.isSearch
                            ? PreferredSize(
                                preferredSize: const Size.fromHeight(60),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  color: Colors.white,
                                  child: SearchField(
                                    title: LocalStrings.customerDetails.tr,
                                    searchController: controller.searchController,
                                    onTap: () => controller.searchCustomer(),
                                  ),
                                ),
                              )
                            : null,
                      ),

                      if (controller.customersModel.overview != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _buildOverviewCard(
                                    context,
                                    LocalStrings.totalCustomers.tr,
                                    controller.customersModel.overview?.customersTotal ?? '0',
                                    Icons.group,
                                    ColorResources.blueColor,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildOverviewCard(
                                    context,
                                    LocalStrings.activeCustomers.tr,
                                    controller.customersModel.overview?.customersActive ?? '0',
                                    Icons.group_add,
                                    ColorResources.greenColor,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildOverviewCard(
                                    context,
                                    LocalStrings.inactiveCustomers.tr,
                                    controller.customersModel.overview?.customersInactive ?? '0',
                                    Icons.group_remove,
                                    ColorResources.redColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      controller.customersModel.data?.isNotEmpty ?? false
                          ? SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: CustomersCard(
                                        index: index,
                                        customerModel: controller.customersModel,
                                      ),
                                    );
                                  },
                                  childCount: controller.customersModel.data!.length,
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

  Widget _buildOverviewCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Container(
      width: 150,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
             overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
