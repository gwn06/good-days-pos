import 'dart:io';

import 'package:flutter/material.dart' as material;
import 'package:csv/csv.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/internal.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/core/values/functions.dart';
import 'package:pos_system/app/data/data_source/employees._data_source.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';
import 'package:pos_system/app/data/enums/sales_date_range.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pos_system/app/data/repository/repository.dart';
import 'package:pos_system/app/modules/sales/widgets/sales_history_table.dart';
import 'package:pos_system/objectbox.g.dart';

class BaseSalesHistory extends ConsumerStatefulWidget {
  final FilterSalesBy filterBy;
  final String header;
  const BaseSalesHistory(
      {required this.filterBy, required this.header, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BaseSaleHistoryState();
}

final dateFormat = DateFormat('EEE, M/d/y hh:mm');

class _BaseSaleHistoryState extends ConsumerState<BaseSalesHistory> {
  late final SalesHistoryDataSource _salesHistoryDataSource;
  late final EmployeeDataSource _employeeDataSource;
  late final Repository _repository;
  late Stream<List<SalesHistory>> _stream;
  late Stream<List<SalesHistory>> _streamSalesByDay;
  late Stream<List<SalesHistory>> _streamSalesByMonth;
  late Stream<List<SalesHistory>> _streamSalesByYear;
  DateTime selectedDate = DateTime.now();
  String selectedDateString = kdates[0];

  @override
  void initState() {
    _salesHistoryDataSource = ref.read(salesHistoryProvider);
    _employeeDataSource = ref.read(employeeDataSourceProvider);
    _repository = ref.read(repositoryProvider);
    _streamSalesByDay = _salesHistoryDataSource
        .getSalesFilteredBy(filter: widget.filterBy, date: DateTime.now())
        .asBroadcastStream();
    _streamSalesByMonth = _salesHistoryDataSource
        .getSalesByDateRange(salesDate: SalesDate.byMonth, date: selectedDate)
        .map((event) => event.entries
            .map((e) => e.value)
            .toList()
            .expand((element) => element)
            .toList())
        .asBroadcastStream();
    _streamSalesByYear = _salesHistoryDataSource
        .getSalesByDateRange(salesDate: SalesDate.byYear, date: selectedDate)
        .map((event) => event.entries
            .map((e) => e.value)
            .toList()
            .expand((element) => element)
            .toList())
        .asBroadcastStream();
    _stream = _streamSalesByDay;
    super.initState();
  }

  String getEmployeeUsername(int id) {
    final employee = _employeeDataSource.getEmployee(id);
    if (employee == null) return '';
    return employee.username;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final salesHistory = snapshot.data as List<SalesHistory>;
            final income = calculateIncome(sales: salesHistory);
            // final total = salesHistory.fold<double>(0.0,
            //     (previousValue, element) => previousValue + element.grandTotal);
            return ScaffoldPage(
                header: PageHeader(
                    title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.header),
                    FilledButton(
                        child: const Text('Export to CSV'),
                        onPressed: () async {
                          List<List<dynamic>> rows = [];
                          List<dynamic> row = [];
                          row.add('id');
                          row.add('amount');
                          row.add('items');
                          row.add('sales rep');
                          row.add('date');
                          row.add('products');
                          rows.add(row);

                          for (var sale in salesHistory) {
                            List<dynamic> row = [];
                            final cart = json.decode(sale.shoppingCart)
                                as Map<String, dynamic>;
                            final List<String> products = [];
                            for (var data in cart.entries) {
                              final cart = ShoppingCart.fromJson(data.value);
                              products
                                  .add('${cart.product.name} : ${cart.amount}');
                            }
                            final username =
                                getEmployeeUsername(sale.employeeId);
                            row.add(sale.id);
                            row.add(sale.grandTotal);
                            row.add(cart.length);
                            row.add(username);
                            row.add(sale.date);
                            row.add(products);
                            rows.add(row);
                          }

                          String csv = const ListToCsvConverter().convert(rows);
                          final dir = await getFilePath();
                          File f = File("$dir/${widget.header}.csv");
                          f.writeAsString(csv);
                          if (!mounted) return;
                          showSnackbar(
                              context,
                              SizedBox(
                                width: 300,
                                height: 80,
                                child: InfoBar(
                                    severity: InfoBarSeverity.success,
                                    title: Text(
                                        'Success! File was saved in $dir directory')),
                              ),
                              duration: const Duration(seconds: 4),
                              alignment: Alignment.topCenter);
                        })
                  ],
                )),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Flexible(
                                    child: Text(
                                  'Revenue $kPeso${numberFormat.format(income.revenue)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeightManager.bold),
                                )),
                              ],
                            ),
                            if (widget.filterBy == FilterSalesBy.selectedDate)
                              Flexible(
                                child: Combobox<String>(
                                  value: selectedDateString,
                                  items: kdates
                                      .map(
                                        (e) => ComboboxItem<String>(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDateString = value!;
                                      updateSalesTable();
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                    child: Text(
                                  'Profit $kPeso${numberFormat.format(income.profit)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeightManager.bold),
                                )),
                              ],
                            ),
                            if (widget.filterBy == FilterSalesBy.selectedDate)
                              Flexible(
                                child: FractionallySizedBox(
                                  widthFactor: 0.2,
                                  child: DatePicker(
                                    selected: selectedDate,
                                    onChanged: (date) {
                                      setState(() {
                                        selectedDate = date;

                                        updateSalesTable();
                                      });
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: SalesHistoryTable(
                              salesHistory: salesHistory,
                              onSort: (columnIndex, ascending) {
                                List<QueryProperty<SalesHistory, dynamic>>
                                    sortFields = [
                                  SalesHistory_.id,
                                  SalesHistory_.grandTotal,
                                  SalesHistory_.grandTotal,
                                  SalesHistory_.grandTotal,
                                  SalesHistory_.date
                                ];
                                setState(() {
                                  _stream = _salesHistoryDataSource
                                      .getSalesFilteredBy(
                                    filter: widget.filterBy,
                                    sortField: sortFields[columnIndex],
                                    ascending: ascending,
                                    date: selectedDate,
                                  );
                                });
                              }),
                        ),
                      ),
                    ],
                  ),
                ));
          }
          return const ProgressBar();
        });
  }

  void updateSalesTable() {
    switch (selectedDateString) {
      case 'Day':
        _streamSalesByDay = _salesHistoryDataSource.getSalesFilteredBy(
          filter: widget.filterBy,
          date: selectedDate,
        );
        _stream = _streamSalesByDay;
        break;
      case 'Month':
        // _stream = _streamSalesByMonth;
        _streamSalesByMonth = _salesHistoryDataSource
            .getSalesByDateRange(
                salesDate: SalesDate.byMonth, date: selectedDate)
            .map((event) => event.entries
                .map((e) => e.value)
                .toList()
                .expand((element) => element)
                .toList());
        _stream = _streamSalesByMonth;
        break;
      case 'Year':
        // _stream = _streamSalesByYear;
        _streamSalesByYear = _salesHistoryDataSource
            .getSalesByDateRange(
                salesDate: SalesDate.byYear, date: selectedDate)
            .map((event) => event.entries
                .map((e) => e.value)
                .toList()
                .expand((element) => element)
                .toList());
        _stream = _streamSalesByYear;
        break;
      default:
    }
  }
}
