import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/data/model/chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LineChart extends StatefulWidget {
  final List<SalesData> chartData;
  const LineChart({Key? key, required this.chartData}) : super(key: key);

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.chartData.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDefaultLineChart();
  }

  SfCartesianChart _buildDefaultLineChart() {
    return SfCartesianChart(
      // plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        labelFormat: '$kPeso{value}',
        numberFormat: NumberFormat.decimalPattern(),
      ),
      title: ChartTitle(text: ''),
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      series: _getDefaultLineSeries(),
      // tooltipBehavior: TooltipBehavior(enable: true),
      trackballBehavior: TrackballBehavior(
          tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
          enable: true,
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
            height: 10,
            width: 10,
            borderWidth: 1,
          ),
          activationMode: ActivationMode.singleTap),
    );
  }

  /// The method returns line series to chart.
  List<LineSeries<SalesData, String>> _getDefaultLineSeries() {
    return <LineSeries<SalesData, String>>[
      LineSeries<SalesData, String>(
          // animationDuration: 2500,
          dataSource: widget.chartData,
          xValueMapper: (SalesData sales, _) => sales.x,
          yValueMapper: (SalesData sales, _) => sales.yRevenue,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          name: 'Revenue',
          markerSettings: const MarkerSettings(isVisible: true)),
      LineSeries<SalesData, String>(
          // animationDuration: 2500,
          dataSource: widget.chartData,
          name: 'Profit',
          xValueMapper: (SalesData sales, _) => sales.x,
          yValueMapper: (SalesData sales, _) => sales.y2Profit,
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }
}
