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
import 'package:flutex_admin/features/dashboard/widget/leads_tasks_card.dart';
import 'package:flutex_admin/features/dashboard/widget/lead_journey_card.dart';
import 'package:flutex_admin/features/dashboard/widget/goals_card.dart';
import 'package:flutex_admin/features/dashboard/widget/leads_status_pie_chart.dart';
import 'package:flutex_admin/features/dashboard/widget/calendar_schedule_card.dart';
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


                          /// NEW WIDGETS SECTION
                          LeadsTasksCard(summary: controller.newStats.leadsTasks),
                          const SizedBox(height: Dimensions.space15),
                          
                          LeadJourneyCard(steps: controller.newStats.leadJourney),
                          const SizedBox(height: Dimensions.space15),
                          
                          GoalsCard(goals: controller.newStats.goals),
                          const SizedBox(height: Dimensions.space15),
                          
                          LeadsStatusPieChart(data: controller.newStats.leadStatusPie),
                          const SizedBox(height: Dimensions.space15),
                          
                          const CalendarScheduleCard(),
                          const SizedBox(height: Dimensions.space20),



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
