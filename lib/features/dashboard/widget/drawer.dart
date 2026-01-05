import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.homeModel});
  final DashboardModel homeModel;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorResources.primaryColor, ColorResources.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: CircleImageWidget(
                      imagePath: homeModel.staff?.formattedProfileImage ?? '',
                      isAsset: false,
                      isProfile: true,
                      width: 72,
                      height: 72,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${homeModel.staff?.firstName ?? ''} ${homeModel.staff?.lastName ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                   onTap: () {
                    Get.back();
                    Get.toNamed(RouteHelper.profileScreen);
                  },
                  child: Row(
                    children: [
                      Text(
                        homeModel.staff?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white.withValues(alpha: 0.8))
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  homeModel.menuItems?.customers ?? false
                      ? buildListTile(
                          leadingIcon: Icons.people_alt_outlined,
                          title: LocalStrings.customers.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.customerScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        LocalStrings.sales.tr,
                        style: mediumDefault.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontSize: 15,
                        ),
                      ),
                      leading: Icon(
                        Icons.monetization_on_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: 22,
                      ),
                      iconColor: ColorResources.primaryColor,
                      childrenPadding: const EdgeInsets.only(left: 16),
                      children: [
                        homeModel.menuItems?.proposals ?? false
                            ? buildListTile(
                                leadingIcon: Icons.description_outlined,
                                title: LocalStrings.proposals.tr,
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.toNamed(RouteHelper.proposalScreen);
                                },
                                isSubItem: true,
                              )
                            : const SizedBox.shrink(),
                        homeModel.menuItems?.estimates ?? false
                            ? buildListTile(
                                leadingIcon: Icons.pie_chart_outline_rounded,
                                title: LocalStrings.estimates.tr,
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.toNamed(RouteHelper.estimateScreen);
                                },
                                isSubItem: true,
                              )
                            : const SizedBox.shrink(),
                        homeModel.menuItems?.invoices ?? false
                            ? buildListTile(
                                leadingIcon: Icons.receipt_long_rounded,
                                title: LocalStrings.invoices.tr,
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.toNamed(RouteHelper.invoiceScreen);
                                },
                                isSubItem: true,
                              )
                            : const SizedBox.shrink(),
                        homeModel.menuItems?.payments ?? false
                            ? buildListTile(
                                leadingIcon:
                                    Icons.account_balance_wallet_outlined,
                                title: LocalStrings.payments.tr,
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.toNamed(RouteHelper.paymentScreen);
                                },
                                isSubItem: true,
                              )
                            : const SizedBox.shrink(),
                        homeModel.menuItems?.items ?? false
                            ? buildListTile(
                                leadingIcon: Icons.inventory_2_outlined,
                                title: LocalStrings.items.tr,
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.toNamed(RouteHelper.itemScreen);
                                },
                                isSubItem: true,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  homeModel.menuItems?.projects ?? false
                      ? buildListTile(
                          leadingIcon: Icons.folder_open_rounded,
                          title: LocalStrings.projects.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.projectScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.tasks ?? false
                      ? buildListTile(
                          leadingIcon: Icons.check_circle_outline_rounded,
                          title: LocalStrings.tasks.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.taskScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.contracts ?? false
                      ? buildListTile(
                          leadingIcon: Icons.gavel_rounded,
                          title: LocalStrings.contracts.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.contractScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.tickets ?? false
                      ? buildListTile(
                          leadingIcon: Icons.confirmation_number_outlined,
                          title: LocalStrings.support.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.ticketScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.leads ?? false
                      ? buildListTile(
                          leadingIcon: Icons.filter_alt_outlined,
                          title: LocalStrings.leads.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.leadScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  buildListTile(
                    leadingIcon: Icons.map_outlined,
                    title: "Sales Trip Tracker",
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(RouteHelper.salesTrackerScreen);
                    },
                  ),
                  buildListTile(
                    leadingIcon: Icons.call_outlined,
                    title: "Telecalling",
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(RouteHelper.telecallingScreen);
                    },
                  ),
                  homeModel.menuItems?.expenses ?? false
                      ? buildListTile(
                          leadingIcon: Icons.money_off_rounded,
                          title: LocalStrings.expenses.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.expenseScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.staff ?? false
                      ? buildListTile(
                          leadingIcon: Icons.group_outlined,
                          title: LocalStrings.staffs.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.staffScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  
                  const Divider(indent: 20, endIndent: 20, height: 30),
                  
                  buildListTile(
                    leadingIcon: Icons.settings_outlined,
                    title: LocalStrings.settings.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(RouteHelper.settingsScreen);
                    },
                  ),
                  
                   ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE), // Light red
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      LocalStrings.logout.tr,
                      style: mediumDefault.copyWith(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      const WarningAlertDialog().warningAlertDialog(
                        context,
                        () {
                          Get.back();
                          Get.find<DashboardController>().logout();
                        },
                        title: LocalStrings.logout.tr,
                        subTitle: LocalStrings.logoutSureWarningMSg.tr,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile({
    required IconData leadingIcon,
    required String title,
    required VoidCallback onTap,
    bool isSubItem = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: isSubItem ? 16 : 24, right: 24, top: 2, bottom: 2),
      leading: isSubItem 
      ? Icon(leadingIcon, size: 20, color: ColorResources.hintColor)
      : Icon(leadingIcon, color: Theme.of(Get.context!).iconTheme.color, size: 22),
      title: Text(
        title,
        style: isSubItem
           ? regularDefault.copyWith(color: ColorResources.contentTextColor, fontSize: 14)
           : mediumDefault.copyWith(
               color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
               fontSize: 15,
             ),
      ),
      trailing: isSubItem ? null : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ColorResources.hintColor),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}
