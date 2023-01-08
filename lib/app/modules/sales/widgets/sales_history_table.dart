import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/data/data_source/employees._data_source.dart';
import 'package:pos_system/app/data/model/employee.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pos_system/app/modules/sales/widgets/product_sales_bottom_sheet.dart';

final dateFormat = DateFormat('EEE, M/d/y hh:mm a');

class SalesHistoryTable extends ConsumerStatefulWidget {
  final List<SalesHistory> salesHistory;
  final void Function(int columnIndex, bool ascending) onSort;
  const SalesHistoryTable({
    Key? key,
    required this.salesHistory,
    required this.onSort,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SalesHistoryTableState();
}

class _SalesHistoryTableState extends ConsumerState<SalesHistoryTable> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  late final EmployeeDataSource _employeeDataSource;
  final ValueNotifier<int> salesHash = ValueNotifier(0);

  @override
  void initState() {
    _employeeDataSource = ref.read(employeeDataSourceProvider);
    super.initState();
  }

  Employee? getEmployee(int id) {
    final employee = _employeeDataSource.getEmployee(id);
    if (employee == null) return null;
    return employee;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      salesHash.value = (widget.salesHistory.hashCode);
    });
    final source = SalesHistoryData(
        sales: widget.salesHistory,
        getEmployee: getEmployee,
        bottomSheet: _showSalesHistoryBottomSheet);

    return material.PaginatedDataTable(
        rowsPerPage: 8,
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        columns: [
          material.DataColumn(
              onSort: _onDataColumnSort,
              label: const Text(
                'ID',
                style: TextStyle(fontWeight: FontWeightManager.semiBold),
              )),
          material.DataColumn(
              onSort: _onDataColumnSort,
              label: const Text(
                'AMOUNT',
                style: TextStyle(fontWeight: FontWeightManager.semiBold),
              )),
          const material.DataColumn(
              label: Text(
            'PRODUCTS',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          const material.DataColumn(
              label: Text(
            'SALES REP',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          material.DataColumn(
              onSort: _onDataColumnSort,
              label: const Text(
                'DATE',
                style: TextStyle(fontWeight: FontWeightManager.semiBold),
              ))
        ],
        source: source);
  }

  void _onDataColumnSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort(_sortColumnIndex, _sortAscending);
  }

  void _showSalesHistoryBottomSheet({
    required int index,
  }) {
    showBottomSheet(
      context: context,
      builder: (context) => ValueListenableBuilder(
        valueListenable: salesHash,
        builder: (context, value, child) {
          if (widget.salesHistory.isEmpty) {
            return Container();
          }
          SalesHistory? sale;
          try {
            sale = widget.salesHistory[index];
          } on RangeError {
            return Container();
          }
          final Map<String, ShoppingCart> cartMap = {};
          final cart = json.decode(sale.shoppingCart) as Map<String, dynamic>;
          for (var data in cart.entries) {
            final product = ShoppingCart.fromJson(data.value);
            cartMap.update(
              data.key,
              (value) => value,
              ifAbsent: () => product,
            );
          }
          final employee = getEmployee(sale.employeeId);
          return SalesBottomSheet(
              sale: sale, cartMap: cartMap, employee: employee);
        },
      ),
    );
  }
}

class SalesHistoryData extends material.DataTableSource {
  final List<SalesHistory> sales;
  final void Function({
    required int index,
  }) bottomSheet;
  final Employee? Function(int id) getEmployee;

  SalesHistoryData({
    required this.sales,
    required this.getEmployee,
    required this.bottomSheet,
  });
  @override
  material.DataRow? getRow(int index) {
    final sale = sales[index];
    final Map<String, ShoppingCart> cartMap = {};
    final cart = json.decode(sale.shoppingCart) as Map<String, dynamic>;
    for (var data in cart.entries) {
      final product = ShoppingCart.fromJson(data.value);
      cartMap.update(
        data.key,
        (value) => value,
        ifAbsent: () => product,
      );
    }
    final employee = getEmployee(sale.employeeId);
    return material.DataRow.byIndex(index: index, cells: [
      material.DataCell(
        Text(sale.id.toString()),
        onTap: () => bottomSheet(index: index),
      ),
      material.DataCell(
        Text('$kPeso${numberFormat.format(sale.grandTotal)}'),
        onTap: () => bottomSheet(index: index),
      ),
      material.DataCell(
        Text(cartMap.length.toString()),
        onTap: () => bottomSheet(index: index),
      ),
      material.DataCell(
        Text(employee?.username ?? ''),
        onTap: () => bottomSheet(index: index),
      ),
      material.DataCell(
        Text(dateFormat.format(sale.date)),
        onTap: () => bottomSheet(index: index),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => sales.length;

  @override
  int get selectedRowCount => 0;
}
