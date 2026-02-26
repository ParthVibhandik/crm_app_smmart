import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';

class LeadsStatusPieChart extends StatelessWidget {
  final Map<String, int> data;
  const LeadsStatusPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine if we have valid data
    bool hasData = data.values.any((val) => val > 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Leads Status',
                style: regularLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (!hasData)
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text("No leads data available")))
            else
              SizedBox(
                height: 250,
                child: SfCircularChart(
                    legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap),
                    series: <CircularSeries>[
                      PieSeries<_ChartData, String>(
                        dataSource: data.entries
                            .map((e) => _ChartData(e.key, e.value))
                            .toList(),
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                        dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside),
                      )
                    ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final int y;
}
