import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutex_admin/common/components/app-bar/action_button_icon_widget.dart';
import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/will_pop_widget.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:flutex_admin/features/dashboard/widget/drawer.dart';
import 'package:flutex_admin/features/dashboard/widget/home_estimates_card.dart';
import 'package:flutex_admin/features/dashboard/widget/home_invoices_card.dart';
import 'package:flutex_admin/features/dashboard/widget/home_proposals_card.dart';
import 'package:flutex_admin/features/attendance/attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Animation Helper
class FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;

  const FadeInUp({super.key, required this.child, this.delay = 0});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _translate = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _translate,
        child: widget.child,
      ),
    );
  }
}

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
      if (mounted) {
        controller.initialData();
      }
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
            drawer: HomeDrawer(homeModel: controller.homeModel),
            body: controller.isLoading
                ? const CustomLoader()
                : RefreshIndicator(
                    onRefresh: () async => await controller.initialData(shouldLoad: false),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(context, controller),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Quick Actions
                              FadeInUp(
                                delay: 100,
                                child: _buildQuickActions(context),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Stats Grid
                              FadeInUp(
                                delay: 200,
                                child: _buildStatsGrid(context, controller),
                              ),
                              
                              const SizedBox(height: 28),
                              
                              // Carousel Section
                              if ((controller.homeModel.menuItems?.invoices ?? false) ||
                                  (controller.homeModel.menuItems?.estimates ?? false) ||
                                  (controller.homeModel.menuItems?.proposals ?? false))
                                FadeInUp(
                                  delay: 300,
                                  child: _buildCarouselSection(controller),
                                ),

                              const SizedBox(height: 28),

                              // Project Statistics
                              if (controller.homeModel.menuItems?.projects ?? false)
                                FadeInUp(
                                  delay: 400,
                                  child: _buildProjectStats(context, controller),
                                ),

                              const SizedBox(height: 100), // Bottom spacing
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, DashboardController controller) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: ColorResources.primaryColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.toNamed(RouteHelper.notificationsScreen),
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorResources.primaryColor,
                Color(0xFF3730A3), // Darker Indigo
                ColorResources.tertiaryColor, // Violet
              ],
            ),
          ),
          child: Stack(
            children: [
              // Abstract Shapes
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withValues(alpha: 0.15), Colors.transparent], 
                    ),
                  ),
                ),
              ),
               Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                      ),
                      child: CircleAvatar(
                        backgroundColor: ColorResources.cardColor,
                        radius: 32,
                        child: CircleImageWidget(
                          imagePath: controller.homeModel.staff?.profileImage ?? '',
                          isAsset: false,
                          isProfile: true,
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              LocalStrings.welcome.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${controller.homeModel.staff?.firstName ?? ''} ${controller.homeModel.staff?.lastName ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () {
          final token = Get.find<ApiClient>().sharedPreferences.getString('access_token');
          if (token == null || token.isEmpty) {
            Get.snackbar('Error', 'Authentication token not found', 
              backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }
          Get.to(() => AttendanceScreen(authToken: token));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorResources.secondaryColor, ColorResources.blueColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorResources.secondaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mark Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to check-in or check-out',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, size: 20, color: ColorResources.primaryColor),
              const SizedBox(width: 10),
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = (width - 16) / 2;
              
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    context,
                    itemWidth,
                    LocalStrings.invoicesAwaitingPayment.tr,
                    controller.homeModel.overview?.invoicesAwaitingPaymentTotal ?? '0',
                    controller.homeModel.overview?.totalInvoices ?? '0',
                    controller.homeModel.overview?.invoicesAwaitingPaymentPercent ?? '0',
                    Icons.attach_money_rounded,
                    ColorResources.yellowColor,
                    onTap: () => Get.toNamed(RouteHelper.invoiceScreen),
                  ),
                  _buildStatCard(
                    context,
                    itemWidth,
                    LocalStrings.convertedLeads.tr,
                    controller.homeModel.overview?.leadsConvertedTotal ?? '0',
                    controller.homeModel.overview?.totalLeads ?? '0',
                    controller.homeModel.overview?.leadsConvertedPercent ?? '0',
                    Icons.move_up_rounded,
                    ColorResources.greenColor,
                    onTap: () => Get.toNamed(RouteHelper.leadScreen),
                  ),
                  _buildStatCard(
                    context,
                    itemWidth,
                    LocalStrings.notCompleted.tr,
                    controller.homeModel.overview?.notFinishedTasksTotal ?? '0',
                    controller.homeModel.overview?.totalTasks ?? '0',
                    controller.homeModel.overview?.notFinishedTasksPercent ?? '0',
                    Icons.task_outlined,
                    ColorResources.primaryColor,
                    onTap: () => Get.toNamed(RouteHelper.taskScreen),
                  ),
                  _buildStatCard(
                    context,
                    itemWidth,
                    LocalStrings.projectsInProgress.tr,
                    controller.homeModel.overview?.projectsInProgressTotal ?? '0',
                    controller.homeModel.overview?.totalProjects ?? '0',
                    controller.homeModel.overview?.inProgressProjectsPercent ?? '0',
                    Icons.dashboard_customize_rounded,
                    ColorResources.secondaryColor,
                    onTap: () => Get.toNamed(RouteHelper.projectScreen),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    double width,
    String title,
    String current,
    String total,
    String percent,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    if (double.tryParse(percent) != null)
                      Stack(
                         alignment: Alignment.center,
                         children: [
                           CircularProgressIndicator(
                             value: double.parse(percent) / 100,
                             strokeWidth: 3,
                             backgroundColor: color.withValues(alpha: 0.1),
                             valueColor: AlwaysStoppedAnimation<Color>(color),
                           ),
                           Text(
                              '${double.parse(percent).toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                           ),
                         ],
                      ).paddingAll(0).sizedBox(width: 36, height: 36),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      current,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorResources.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorResources.contentTextColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 20, color: ColorResources.primaryColor),
              const SizedBox(width: 10),
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 420.0,
            viewportFraction: 0.92,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: (index, i) {
              controller.currentPageIndex = index;
              controller.update();
            },
          ),
          items: [
            if (controller.homeModel.menuItems?.invoices ?? false)
              HomeInvoicesCard(
                invoices: controller.homeModel.data?.invoices,
              ),
            if (controller.homeModel.menuItems?.estimates ?? false)
              HomeEstimatesCard(
                estimates: controller.homeModel.data?.estimates,
              ),
            if (controller.homeModel.menuItems?.proposals ?? false)
              HomeProposalsCard(
                proposals: controller.homeModel.data?.proposals,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectStats(BuildContext context, DashboardController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ColorResources.tertiaryColor, ColorResources.tertiaryColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  LocalStrings.projectStatistics.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
         const SizedBox(height: 24),
         SizedBox(
           height: 200,
           child: SfCircularChart(
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.right,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                iconHeight: 10,
                iconWidth: 10,
              ),
              series: <CircularSeries>[
                DoughnutSeries<DataField, String>(
                  dataSource: controller.homeModel.data?.projects,
                  xValueMapper: (DataField data, _) => data.status?.tr ?? '',
                  yValueMapper: (DataField data, _) => int.parse(data.total ?? '0'),
                  pointColorMapper: (DataField data, _) => ColorResources.projectStatusColor(data.status.toString()),
                  innerRadius: '65%',
                  radius: '100%',
                  cornerStyle: CornerStyle.bothCurve,
                  dataLabelSettings: const DataLabelSettings(
                     isVisible: true,
                     labelPosition: ChartDataLabelPosition.outside,
                     connectorLineSettings: ConnectorLineSettings(type: ConnectorType.curve),
                  ),
                ),
              ],
            ),
         ),
        ],
      ),
    );
  }
}

extension SizedBoxExtension on Widget {
  Widget sizedBox({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }
}
