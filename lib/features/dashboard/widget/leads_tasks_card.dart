import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:get/get.dart';

class LeadsTasksCard extends StatefulWidget {
  final DashboardController controller;
  const LeadsTasksCard({super.key, required this.controller});

  @override
  State<LeadsTasksCard> createState() => _LeadsTasksCardState();
}

class _LeadsTasksCardState extends State<LeadsTasksCard> {
  String _lastFilterKey = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      // Generate unique key for current filter state
      String currentFilterKey =
          '${controller.selectedLeadsCategory}_${controller.selectedLeadsMainTab}_${controller.selectedLeadsSubTab}';

      // Reset expansion if filters have changed
      if (currentFilterKey != _lastFilterKey) {
        // We can safely update this state during build because it's derived from the controller state
        // and we want it to reflect immediately in this build pass.
        _lastFilterKey = currentFilterKey;
      }

      // Use unified subordinates from controller (includes both goals and leads/tasks)
      List<DashboardSubordinate> unifiedSubs = controller.unifiedSubordinates;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.space15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Category Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leads & Tasks',
                    style: regularLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildCategoryButton(controller, 'leads', 'Leads'),
                      const SizedBox(width: 8),
                      _buildCategoryButton(controller, 'tasks', 'Tasks'),
                    ],
                  )
                ],
              ),
              const SizedBox(height: Dimensions.space15),

              // Main Tabs (My / Subordinates)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMainTabButton(
                        'My',
                        controller.selectedLeadsMainTab == 'my',
                        () => controller.changeLeadsMainTab('my')),
                    if (unifiedSubs.isNotEmpty)
                      ...unifiedSubs.map((sub) {
                        String name = sub.name;
                        bool isSelected =
                            controller.selectedLeadsMainTab == sub.id;
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _buildMainTabButton(name, isSelected,
                              () => controller.changeLeadsMainTab(sub.id)),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Sub Tabs (Today / Pending) - ONLY FOR LEADS
              if (controller.selectedLeadsCategory == 'leads') ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildSubTabButton(
                        'Today (${_getTabCount(controller, 'today')})',
                        controller.selectedLeadsSubTab == 'today',
                        () => controller.changeLeadsSubTab('today'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSubTabButton(
                        'Pending (${_getTabCount(controller, 'pending')})',
                        controller.selectedLeadsSubTab == 'pending',
                        () => controller.changeLeadsSubTab('pending'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],

              // Content List
              _buildContentList(controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryButton(
      DashboardController controller, String value, String label) {
    bool isSelected = controller.selectedLeadsCategory == value;
    return InkWell(
      onTap: () => controller.changeLeadsCategory(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorResources.primaryColor : Colors.white,
          border: Border.all(color: ColorResources.primaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: regularDefault.copyWith(
              color: isSelected ? Colors.white : ColorResources.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMainTabButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ColorResources.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: regularDefault.copyWith(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildSubTabButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorResources.primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? ColorResources.primaryColor
                  : (Colors.grey[300] ?? Colors.grey)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: regularDefault.copyWith(
              color: isSelected ? ColorResources.primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildContentList(DashboardController controller) {
    List<LeadTaskItem> items = [];
    LeadsTasks? data = controller.homeModel.leadsTasks;

    if (data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No data found.", style: regularDefault),
        ),
      );
    }

    // LEADS LOGIC
    if (controller.selectedLeadsCategory == 'leads') {
      if (controller.selectedLeadsMainTab == 'my') {
        if (controller.selectedLeadsSubTab == 'today') {
          items = data.todaySelf ?? [];
        } else {
          items = data.pendingSelf ?? [];
        }
      } else {
        // Subordinates Logic - Use unified subordinate list
        String staffId = controller.selectedLeadsMainTab;
        DashboardSubordinate? sub = controller.unifiedSubordinates
            .firstWhereOrNull((s) => s.id == staffId);

        if (sub != null) {
          String keyName = sub.name;

          if (controller.selectedLeadsSubTab == 'today') {
            items = data.todaySubords?[keyName] ?? [];
          } else {
            items = data.pendingSubords?[keyName] ?? [];
          }
        }
      }
    }
    // TASKS LOGIC
    else {
      print(
          "[DEBUG] LeadsTasksCard: Task Logic - MainTab: ${controller.selectedLeadsMainTab}");
      if (controller.selectedLeadsMainTab == 'my') {
        items = data.selfTasks ?? [];
        print("[DEBUG] Self Tasks Count: ${items.length}");
      } else {
        // Subordinates Logic - Use unified subordinate list
        String staffId = controller.selectedLeadsMainTab;
        DashboardSubordinate? sub = controller.unifiedSubordinates
            .firstWhereOrNull((s) => s.id == staffId);

        print("[DEBUG] Subordinate Lookup: ID=$staffId, Found=${sub?.name}");
        if (sub != null) {
          String keyName = sub.name;
          print("[DEBUG] Looking for tasks for key: '$keyName'");
          print(
              "[DEBUG] Available Subordinate Task Keys: ${data.subordinatesTasks?.keys.toList()}");

          items = data.subordinatesTasks?[keyName] ?? [];
          print("[DEBUG] Found ${items.length} tasks for $keyName");
        }
      }
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No items found for ${controller.selectedLeadsCategory}.",
              style: regularDefault),
        ),
      );
    }

    // Truncation Logic
    bool showViewMore = items.length > 5;
    List<LeadTaskItem> visibleItems =
        (!showViewMore) ? items : items.take(5).toList();

    return Column(
      children: [
        ...visibleItems.map((item) => _buildListItem(controller, item)),
        if (showViewMore)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InkWell(
              onTap: () {
                if (controller.selectedLeadsCategory == 'leads') {
                  Get.toNamed(RouteHelper.leadScreen);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "View More",
                  style: regularDefault.copyWith(
                    color: ColorResources.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListItem(DashboardController controller, LeadTaskItem item) {
    return InkWell(
      onTap: () {
        // Only navigate for leads, not tasks
        if (controller.selectedLeadsCategory == 'leads' && item.id != null) {
          Get.toNamed(RouteHelper.leadDetailsScreen, arguments: item.id);
        } else if (controller.selectedLeadsCategory == 'tasks' &&
            item.id != null) {
          Get.toNamed(RouteHelper.taskDetailsScreen, arguments: item.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name ?? item.subject ?? 'No Name',
                  style: regularDefault.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (item.title != null && item.title!.isNotEmpty)
              Text(
                item.title!,
                style: regularSmall.copyWith(color: Colors.black87),
              ),
            if (item.company != null && item.company!.isNotEmpty)
              Text(
                item.company!,
                style: regularSmall.copyWith(color: Colors.grey[600]),
              ),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: regularSmall.copyWith(color: Colors.grey[500]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }

  int _getTabCount(DashboardController controller, String type) {
    LeadsTasks? data = controller.homeModel.leadsTasks;
    if (data == null) return 0;

    // Only strictly relevant for Leads category where tabs exist
    if (controller.selectedLeadsMainTab == 'my') {
      if (type == 'today') return data.todaySelf?.length ?? 0;
      if (type == 'pending') return data.pendingSelf?.length ?? 0;
    } else {
      // Use unified subordinate list
      String staffId = controller.selectedLeadsMainTab;
      DashboardSubordinate? sub = controller.unifiedSubordinates
          .firstWhereOrNull((s) => s.id == staffId);
      if (sub != null) {
        String keyName = sub.name;
        if (type == 'today') return data.todaySubords?[keyName]?.length ?? 0;
        if (type == 'pending') {
          return data.pendingSubords?[keyName]?.length ?? 0;
        }
      }
    }
    return 0;
  }
}
