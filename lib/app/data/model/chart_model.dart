class SalesData {
  SalesData(this.x, {required this.yRevenue, required this.y2Profit});
  final String x;
  final double yRevenue;
  final double y2Profit;
}

class PieChartData {
  final String x;
  final int y;

  PieChartData({required this.x, required this.y});
}
