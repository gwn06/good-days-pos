import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/data/model/chart_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChart extends StatefulWidget {
  final List<PieChartData> chartData;
  const PieChart({Key? key, required this.chartData}) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  @override
  Widget build(BuildContext context) {
    return _buildDefaultPieChart();
  }

  SfCircularChart _buildDefaultPieChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Items Sold Today'),
      legend: Legend(isVisible: true),
      series: _getDefaultPieSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<PieSeries<PieChartData, String>> _getDefaultPieSeries() {
    return <PieSeries<PieChartData, String>>[
      PieSeries<PieChartData, String>(
          explode: true,
          explodeIndex: 0,
          explodeOffset: '10%',
          dataSource: widget.chartData,
          xValueMapper: (PieChartData data, _) => data.x,
          yValueMapper: (PieChartData data, _) => data.y,
          dataLabelMapper: (PieChartData data, _) => '${data.x} :${data.y}',
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: const DataLabelSettings(
            margin: EdgeInsets.zero,
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings:
                ConnectorLineSettings(type: ConnectorType.curve, length: '20%'),
          ))
    ];
  }
}
