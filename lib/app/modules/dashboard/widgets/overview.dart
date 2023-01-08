import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/colors.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/core/values/functions.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/data_source/local_data_source.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';
import 'package:pos_system/app/data/enums/sales_date_range.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/income.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/app/data/model/chart_model.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'package:pos_system/app/modules/dashboard/widgets/horizontal_line_title.dart';
import 'package:pos_system/app/modules/dashboard/widgets/line_chart.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pos_system/app/modules/dashboard/widgets/pie_chart.dart';

class Overview extends ConsumerStatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OverviewState();
}

class _OverviewState extends ConsumerState<Overview> {
  late final SalesHistoryDataSource _salesHistoryDataSource;
  late final LocalDataSource _localDataSource;
  late Stream<List<SalesHistory>> _allSales;
  late Stream<List<SalesHistory>> _todaysSales;
  late Stream<Map<String, List<SalesHistory>>> _getDailySales;
  late Stream<Map<String, List<SalesHistory>>> _getMonthlySales;
  late Stream<Map<String, List<SalesHistory>>> _getAnnualSales;

  @override
  void initState() {
    _salesHistoryDataSource = ref.read(salesHistoryProvider);
    _localDataSource = ref.read(localDataSourceProvider);
    _allSales = _salesHistoryDataSource.getSalesFilteredBy(
        filter: FilterSalesBy.allSales);
    _todaysSales = _salesHistoryDataSource
        .getSalesFilteredBy(filter: FilterSalesBy.todaysSale)
        .asBroadcastStream();
    _getDailySales = _salesHistoryDataSource
        .getSalesByDateRange(salesDate: SalesDate.in7Days)
        .asBroadcastStream();
    _getMonthlySales = _salesHistoryDataSource.getSalesByDateRange(
        salesDate: SalesDate.in12Months);
    _getAnnualSales = _salesHistoryDataSource.getSalesByDateRange(
        salesDate: SalesDate.in5Years);
    super.initState();
  }

  // Income calculateIncome({required List<SalesHistory> sales}) {
  //   double profit = 0;
  //   double revenue = 0;
  //   double discounts = 0;
  //   double totalCosts = 0;
  //   for (final sale in sales) {
  //     discounts += sale.discount;
  //     final cart = json.decode(sale.shoppingCart) as Map<String, dynamic>;
  //     for (var data in cart.entries) {
  //       final product = ShoppingCart.fromJson(data.value);
  //       revenue += (product.amount * product.product.sellingPrice);
  //       totalCosts += (product.amount * product.product.costPrice);
  //     }
  //   }
  //   profit = revenue - totalCosts - discounts;
  //   return Income(profit: profit, revenue: revenue, discounts: discounts);
  // }

  List<PieChartData> getPieChartDataFromSales(List<SalesHistory> salesHistory) {
    List<PieChartData> chartData = [];
    Map<String, int> productNameAndAmount = {};
    for (var sale in salesHistory) {
      final cart = json.decode(sale.shoppingCart) as Map<String, dynamic>;
      for (var data in cart.entries) {
        final product = ShoppingCart.fromJson(data.value);
        productNameAndAmount.update(
          product.product.name,
          (value) => value + product.amount,
          ifAbsent: () => product.amount,
        );
      }
    }

    for (var product in productNameAndAmount.entries) {
      chartData.add(PieChartData(x: product.key, y: product.value));
    }
    return chartData;
  }

  double getStockValue({required List<ProductInfo> products}) {
    double stockValue = 0;
    for (var product in products) {
      stockValue += product.availableQuantity * product.sellingPrice;
    }
    return stockValue;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(AppStrings.dashboard),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) => Text(
              DateFormat('EEE, MMM dd  hh:mm a').format(DateTime.now()),
            ),
          )
        ],
      )),
      content: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: [
                _buildAnalyticsCard(),
                SizedBox(
                  height: 300,
                  child: StreamBuilder(
                    stream: _todaysSales,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final salesHistoryToday =
                            snapshot.data as List<SalesHistory>;
                        final chartData =
                            getPieChartDataFromSales(salesHistoryToday);
                        return PieChart(chartData: chartData);
                      }
                      return const ProgressBar();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              const HorizontalLineTitle(title: 'Daily Sales & Profit'),
              const SizedBox(height: 10),
              _buildLineChart(_getDailySales),
              const SizedBox(height: 30),
              const HorizontalLineTitle(title: 'Monthly Sales & Profit'),
              const SizedBox(height: 10),
              _buildLineChart(_getMonthlySales),
              const SizedBox(height: 10),
              const HorizontalLineTitle(title: 'Annual Sales & Profit'),
              const SizedBox(height: 10),
              _buildLineChart(_getAnnualSales),
            ],
          ),
        ))
      ]),
    );
  }

  Padding _buildAnalyticsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30),
      child: SizedBox(
        height: 320,
        child: material.Card(
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: ColorManager.grey2),
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                          fontSize: FontSize.s28,
                          fontWeight: FontWeightManager.semiBold),
                    ),
                    StreamBuilder<List<ProductInfo>>(
                        stream: _localDataSource.getAllProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final products = snapshot.data as List<ProductInfo>;
                            final stockValue =
                                getStockValue(products: products);
                            return _buildCardData(
                                value:
                                    '$kPeso${numberFormat.format(stockValue)}',
                                title: 'Stock Value',
                                textColor: ColorManager.green5);
                          }
                          return const ProgressBar();
                        }),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StreamBuilder(
                          stream: _todaysSales,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final todaysSalesList =
                                  snapshot.data as List<SalesHistory>;
                              final income =
                                  calculateIncome(sales: todaysSalesList);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCardData(
                                    value:
                                        '\u20B1${numberFormat.format(income.revenue)}',
                                    title: 'Today\'s Revenue',
                                    color: ColorManager.lightOrange,
                                    textColor: ColorManager.pink5,
                                  ),
                                  _buildCardData(
                                      value:
                                          '\u20B1${numberFormat.format(income.profit)}',
                                      title: 'Today\'s Profit',
                                      textColor: ColorManager.teal05),
                                  _buildCardData(
                                      value:
                                          '\u20B1${numberFormat.format(income.discounts)}',
                                      title: 'Today\'s Discount',
                                      textColor: ColorManager.red5),
                                ],
                              );
                            }
                            return const ProgressBar();
                          }),
                      StreamBuilder(
                          stream: _allSales,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final allSales =
                                  snapshot.data as List<SalesHistory>;
                              final income = calculateIncome(sales: allSales);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCardData(
                                    value:
                                        '\u20B1${numberFormat.format(income.revenue)}',
                                    title: 'Total Revenue',
                                    textColor: ColorManager.indigo5,
                                  ),
                                  _buildCardData(
                                    value:
                                        '\u20B1${numberFormat.format(income.profit)}',
                                    title: 'Total Profit',
                                    textColor: ColorManager.blue5,
                                  ),
                                  _buildCardData(
                                    value:
                                        '\u20B1${numberFormat.format(income.discounts)}',
                                    title: 'Total Discount',
                                    textColor: ColorManager.red4,
                                  ),
                                ],
                              );
                            }
                            return const ProgressBar();
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildLineChart(
      Stream<Map<String, List<SalesHistory>>> salesByDateStream) {
    return SizedBox(
        width: 600,
        child: StreamBuilder(
            stream: salesByDateStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final dailySalesMap =
                    snapshot.data as Map<String, List<SalesHistory>>;
                List<SalesData> chartDataList = [];
                for (final sales in dailySalesMap.entries) {
                  final income = calculateIncome(sales: sales.value);
                  chartDataList.add(SalesData(sales.key,
                      yRevenue: income.revenue, y2Profit: income.profit));
                }

                return LineChart(chartData: chartDataList);
              }
              return const ProgressBar();
            }));
  }

  Container _buildCardData(
      {required String value,
      required String title,
      Color? color,
      Color textColor = ColorManager.grey6}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        width: 140,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            value,
            style: TextStyle(
                color: textColor,
                fontSize: FontSize.s25,
                fontWeight: FontWeightManager.semiBold),
          ),
          Text(
            title,
            style: const TextStyle(color: ColorManager.grey5),
          ),
        ]),
      ),
    );
  }
}
