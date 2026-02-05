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
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              '${homeModel.staff?.firstName ?? ''} ${homeModel.staff?.lastName ?? ''}',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: mediumLarge.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              homeModel.staff?.email ?? '',
              style: lightDefault.copyWith(color: Colors.white),
            ),
            onDetailsPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.profileScreen);
            },
            currentAccountPicture: CircleAvatar(
              child: CircleImageWidget(
                imagePath: homeModel.staff?.formattedProfileImage ?? '',
                isAsset: false,
                isProfile: true,
                width: 80,
                height: 80,
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                  ColorResources.primaryColor.withValues(alpha: 0.6),
                  BlendMode.multiply,
                ),
                image: AssetImage(MyImages.login),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  homeModel.menuItems?.customers ?? false
                      ? buildListTile(
                          leadingIcon: Icons.person_outline,
                          title: LocalStrings.customers.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.customerScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  ExpansionTile(
                    title: Text(
                      LocalStrings.sales.tr,
                      style: regularDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    leading: Icon(
                      Icons.electric_bolt_rounded,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    iconColor: Theme.of(
                      Get.context!,
                    ).textTheme.bodyLarge!.color,
                    collapsedIconColor: Theme.of(
                      Get.context!,
                    ).textTheme.bodyLarge!.color,
                    children: [
                      homeModel.menuItems?.proposals ?? false
                          ? buildListTile(
                              leadingIcon: Icons.document_scanner_outlined,
                              title: LocalStrings.proposals.tr,
                              onTap: () {
                                Navigator.pop(context);
                                Get.toNamed(RouteHelper.proposalScreen);
                              },
                            )
                          : const SizedBox.shrink(),
                      homeModel.menuItems?.estimates ?? false
                          ? buildListTile(
                              leadingIcon: Icons.add_chart_outlined,
                              title: LocalStrings.estimates.tr,
                              onTap: () {
                                Navigator.pop(context);
                                Get.toNamed(RouteHelper.estimateScreen);
                              },
                            )
                          : const SizedBox.shrink(),
                      homeModel.menuItems?.invoices ?? false
                          ? buildListTile(
                              leadingIcon: Icons.assignment_outlined,
                              title: LocalStrings.invoices.tr,
                              onTap: () {
                                Navigator.pop(context);
                                Get.toNamed(RouteHelper.invoiceScreen);
                              },
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
                            )
                          : const SizedBox.shrink(),
                      homeModel.menuItems?.items ?? false
                          ? buildListTile(
                              leadingIcon: Icons.add_box_outlined,
                              title: LocalStrings.items.tr,
                              onTap: () {
                                Navigator.pop(context);
                                Get.toNamed(RouteHelper.itemScreen);
                              },
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  homeModel.menuItems?.projects ?? false
                      ? buildListTile(
                          leadingIcon: Icons.folder_open_outlined,
                          title: LocalStrings.projects.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.projectScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.tasks ?? false
                      ? buildListTile(
                          leadingIcon: Icons.task_alt_rounded,
                          title: LocalStrings.tasks.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.taskScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.contracts ?? false
                      ? buildListTile(
                          leadingIcon: Icons.article_outlined,
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
                          leadingIcon: Icons.markunread_mailbox_outlined,
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
                  buildListTile(
                    leadingIcon: Icons.edit_calendar_outlined,
                    title: "Regularize Attendance",
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(RouteHelper.regularizationScreen);
                    },
                  ),
                  buildListTile(
                    leadingIcon: Icons.flag_outlined,
                    title: "Goals",
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(RouteHelper.goalScreen);
                    },
                  ),

                  homeModel.menuItems?.expenses ?? false
                      ? buildListTile(
                          leadingIcon: Icons.monetization_on_outlined,
                          title: LocalStrings.expenses.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.expenseScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  homeModel.menuItems?.staff ?? false
                      ? buildListTile(
                          leadingIcon: Icons.person_4_outlined,
                          title: LocalStrings.staffs.tr,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(RouteHelper.staffScreen);
                          },
                        )
                      : const SizedBox.shrink(),
                  buildListTile(
                    leadingIcon: Icons.settings_outlined,
                    title: LocalStrings.settings.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(RouteHelper.settingsScreen);
                    },
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              size: Dimensions.space20,
              color: Colors.red,
            ),
            title: Text(
              LocalStrings.logout.tr,
              style: regularDefault.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
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
    );
  }

  Widget buildListTile({
    required IconData leadingIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
      ),
      title: Text(
        title,
        style: regularDefault.copyWith(
          color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
        ),
      ),
      onTap: onTap,
    );
  }
}
