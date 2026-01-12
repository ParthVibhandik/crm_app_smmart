import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutex_admin/common/components/app-bar/action_button_icon_widget.dart';
import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/will_pop_widget.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:flutex_admin/features/dashboard/widget/dashboard_card.dart';
import 'package:flutex_admin/features/dashboard/widget/drawer.dart';
import 'package:flutex_admin/features/dashboard/widget/home_estimates_card.dart';
import 'package:flutex_admin/features/dashboard/widget/home_invoices_card.dart';
import 'package:flutex_admin/features/dashboard/widget/home_proposals_card.dart';
import 'package:flutex_admin/features/attendance/attendance_screen.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(DashboardRepo(apiClient: Get.find()));
    final controller = Get.put(DashboardController(dashboardRepo: Get.find()));
    controller.isLoading = true;

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: GetBuilder<DashboardController>(
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              toolbarHeight: 60,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).openAppDrawerTooltip,
                  );
                },
              ),
              centerTitle: true,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  MyImages.appLogo,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              actions: [
                ActionButtonIconWidget(
                  pressed: () => Get.toNamed(RouteHelper.notificationsScreen),
                  icon: Icons.notifications,
                  size: 35,
                  iconColor: Colors.white,
                ),
              ],
            ),
            drawer: HomeDrawer(homeModel: controller.homeModel),
            body: controller.isLoading
                ? const CustomLoader()
                : RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).cardColor,
                    onRefresh: () async {
                      await controller.initialData(shouldLoad: false);
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(Dimensions.space10),
                      child: Column(
                        children: [
                          /// PROFILE + WELCOME
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: ColorResources.blueGreyColor,
                                  radius: 32,
                                  child: CircleImageWidget(
                                    imagePath: controller
                                            .homeModel.staff?.profileImage ??
                                        '',
                                    isAsset: false,
                                    isProfile: true,
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space20),
                                SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.65,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${LocalStrings.welcome.tr} ',
                                              style: regularLarge.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium!.color,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${controller.homeModel.staff?.firstName ?? ''} ${controller.homeModel.staff?.lastName ?? ''}',
                                              style: regularLarge.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium!.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => UrlLauncherHelper.mail(
                                            controller.homeModel.staff?.email),
                                        child: Text(
                                          controller.homeModel.staff?.email ??
                                              '',
                                          style: regularSmall.copyWith(
                                            color: ColorResources.blueGreyColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 🟢 MARK ATTENDANCE BUTTON (ADDED)
                          const SizedBox(height: Dimensions.space15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Mark Attendance'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final token = Get.find<ApiClient>()
                                    .sharedPreferences
                                    .getString('access_token');

                                if (token == null || token.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Authentication token not found',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                Get.to(
                                  () => AttendanceScreen(authToken: token),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: Dimensions.space15),

                          /// ATTENDANCE CALENDAR
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.cardRadius),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TableCalendar(
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: controller.focusedDay,
                                    currentDay: DateTime.now(),
                                    selectedDayPredicate: (day) =>
                                        isSameDay(controller.selectedDay, day),
                                    calendarFormat: CalendarFormat.month,
                                    startingDayOfWeek: StartingDayOfWeek.monday,
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                    ),
                                    availableGestures: AvailableGestures.all,
                                    onDaySelected: controller.onDaySelected,
                                    onPageChanged: (focusedDay) {
                                      controller.focusedDay = focusedDay;
                                    },
                                    calendarStyle: CalendarStyle(
                                      selectedDecoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  if (controller.selectedDay != null || controller.isAttendanceLoading) ...[
                                    const CustomDivider(),
                                    const SizedBox(height: 10),
                                    if (controller.isAttendanceLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      )
                                    else
                                      Column(
                                        children: [
                                          Text(
                                            DateFormat('MMMM d, y').format(controller.selectedDay!),
                                            style: boldLarge,
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text('Punch In', style: regularDefault.copyWith(color: ColorResources.blueGreyColor)),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    controller.punchInTime ?? '--:--',
                                                    style: boldExtraLarge.copyWith(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 40,
                                                width: 1,
                                                color: Colors.grey.withOpacity(0.3),
                                              ),
                                              Column(
                                                children: [
                                                  Text('Punch Out', style: regularDefault.copyWith(color: ColorResources.blueGreyColor)),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    controller.punchOutTime ?? '--:--',
                                                    style: boldExtraLarge.copyWith(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                  ] else
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Select a date to view attendance details',
                                        style: regularSmall.copyWith(
                                          color: ColorResources.blueGreyColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: Dimensions.space15),

                          /// DASHBOARD STATS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DashboardCard(
                                currentValue: controller.homeModel.overview
                                        ?.invoicesAwaitingPaymentTotal ??
                                    '0',
                                totalValue: controller
                                        .homeModel.overview?.totalInvoices ??
                                    '0',
                                percent: controller.homeModel.overview
                                        ?.invoicesAwaitingPaymentPercent ??
                                    '0',
                                icon: Icons.attach_money_rounded,
                                title: LocalStrings.invoicesAwaitingPayment.tr,
                              ),
                              DashboardCard(
                                currentValue: controller.homeModel.overview
                                        ?.leadsConvertedTotal ??
                                    '0',
                                totalValue:
                                    controller.homeModel.overview?.totalLeads ??
                                        '0',
                                percent: controller.homeModel.overview
                                        ?.leadsConvertedPercent ??
                                    '0',
                                icon: Icons.move_up_rounded,
                                title: LocalStrings.convertedLeads.tr,
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              DashboardCard(
                                currentValue: controller.homeModel.overview
                                        ?.notFinishedTasksTotal ??
                                    '0',
                                totalValue:
                                    controller.homeModel.overview?.totalTasks ??
                                        '0',
                                percent: controller.homeModel.overview
                                        ?.notFinishedTasksPercent ??
                                    '0',
                                icon: Icons.task_outlined,
                                title: LocalStrings.notCompleted.tr,
                              ),
                              DashboardCard(
                                currentValue: controller.homeModel.overview
                                        ?.projectsInProgressTotal ??
                                    '0',
                                totalValue: controller
                                        .homeModel.overview?.totalProjects ??
                                    '0',
                                percent: controller.homeModel.overview
                                        ?.inProgressProjectsPercent ??
                                    '0',
                                icon: Icons.dashboard_customize_rounded,
                                title: LocalStrings.projectsInProgress.tr,
                              ),
                            ],
                          ),

                          /// CAROUSEL (INVOICES / ESTIMATES / PROPOSALS)
                          if ((controller.homeModel.menuItems?.invoices ??
                                  false) ||
                              (controller.homeModel.menuItems?.estimates ??
                                  false) ||
                              (controller.homeModel.menuItems?.proposals ??
                                  false))
                            Stack(
                              children: [
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: 440.0,
                                    viewportFraction: 1,
                                    onPageChanged: (index, i) {
                                      controller.currentPageIndex = index;
                                      controller.update();
                                    },
                                  ),
                                  items: [
                                    if (controller
                                            .homeModel.menuItems?.invoices ??
                                        false)
                                      HomeInvoicesCard(
                                        invoices:
                                            controller.homeModel.data?.invoices,
                                      ),
                                    if (controller
                                            .homeModel.menuItems?.estimates ??
                                        false)
                                      HomeEstimatesCard(
                                        estimates: controller
                                            .homeModel.data?.estimates,
                                      ),
                                    if (controller
                                            .homeModel.menuItems?.proposals ??
                                        false)
                                      HomeProposalsCard(
                                        proposals: controller
                                            .homeModel.data?.proposals,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
