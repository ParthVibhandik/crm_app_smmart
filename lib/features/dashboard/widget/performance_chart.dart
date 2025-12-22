import 'package:flutex_admin/common/components/card/glass_card.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutex_admin/core/service/report_service.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PerformanceChart extends StatelessWidget {
  const PerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Trend',
                style: semiBoldLarge.copyWith(color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  final controller = Get.find<DashboardController>();
                  ReportService.generateDashboardReport(
                    staffName: '${controller.homeModel.staff?.firstName ?? ''} ${controller.homeModel.staff?.lastName ?? ''}',
                    totalInvoices: controller.homeModel.overview?.totalInvoices ?? '0',
                    totalLeads: controller.homeModel.overview?.totalLeads ?? '0',
                    totalTasks: controller.homeModel.overview?.totalTasks ?? '0',
                    totalProjects: controller.homeModel.overview?.totalProjects ?? '0',
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white70),
                tooltip: 'Export Report',
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Weekly growth and conversion rate',
            style: regularSmall.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: RepaintBoundary(
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<ChartData, String>>[
                  SplineSeries<ChartData, String>(
                    dataSource: [
                      ChartData('Mon', 10),
                      ChartData('Tue', 15),
                      ChartData('Wed', 12),
                      ChartData('Thu', 18),
                      ChartData('Fri', 25),
                      ChartData('Sat', 22),
                      ChartData('Sun', 30),
                    ],
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    name: 'Growth',
                    color: Colors.blueAccent,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  SplineSeries<ChartData, String>(
                    dataSource: [
                      ChartData('Mon', 5),
                      ChartData('Tue', 8),
                      ChartData('Wed', 7),
                      ChartData('Thu', 10),
                      ChartData('Fri', 15),
                      ChartData('Sat', 12),
                      ChartData('Sun', 18),
                    ],
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    name: 'Conversion',
                    color: Colors.purpleAccent,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
