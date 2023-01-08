import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/colors.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/core/values/functions.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';
import 'package:pos_system/app/data/managers/product_batch_manager.dart';
import 'package:pos_system/app/data/model/employee.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import 'package:pos_system/app/data/repository/repository.dart';

final dateFormat = DateFormat('EEE, M/d/y hh:mm a');

class SalesBottomSheet extends ConsumerStatefulWidget {
  final Map<String, ShoppingCart> cartMap;
  final Employee? employee;
  final SalesHistory sale;

  const SalesBottomSheet({
    Key? key,
    required this.sale,
    required this.cartMap,
    required this.employee,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SalesBottomSheetState();
}

class _SalesBottomSheetState extends ConsumerState<SalesBottomSheet> {
  late final SalesHistoryDataSource _salesHistoryDataSource;
  late final Repository _repository;
  final ProductBatchManager _batchManager = ProductBatchManagerImpl();
  String fullname = '';

  void _returnItem(int id) {
    final item = widget.cartMap.remove(id.toString())!;

    final itemPriceAmount = item.product.sellingPrice * item.amount;
    // final percentDiscount = widget.sale.discount / widget.sale.subtotal;
    final subtotal = widget.sale.subtotal - itemPriceAmount;
    final grandTotal = subtotal - widget.sale.discount;
    final updatedSale = widget.sale.copyWith(
        grandTotal: grandTotal,
        subtotal: subtotal,
        shoppingCart: json.encode(widget.cartMap));
    _salesHistoryDataSource.updateSalesHistory(updatedSale);

    final oldProduct = _repository.findProduct(id: item.product.id);
    if (oldProduct == null) return;
    final oldBatchList =
        oldProduct.batchList.map((e) => ProductBatch.fromJson(e)).toList();
    final toReturnBatch =
        item.product.batchList.map((e) => ProductBatch.fromJson(e)).toList();
    final updatedBatchList = _batchManager.getIncreasedProductBatch(
        batchList: oldBatchList, toReturn: toReturnBatch);
    final updatedQuantity =
        _batchManager.calculateAvailableStock(updatedBatchList);
    final updatedQuantitySold = oldProduct.quantitySold - item.amount;
    final updateProduct = oldProduct.copyWith(
        quantitySold: updatedQuantitySold,
        availableQuantity: updatedQuantity,
        batchList: updatedBatchList.map((e) => e.toJson()).toList());
    _repository.updateProduct(product: updateProduct);
    showTopSnackbar(
        context: context,
        message: 'Item returned',
        severity: InfoBarSeverity.info,
        title: '');
    if (widget.cartMap.isEmpty) {
      _salesHistoryDataSource.removeSaleHistory(widget.sale.id);
      Navigator.pop(context);
      return;
    }
    setState(() {});
  }

  @override
  void initState() {
    _salesHistoryDataSource = ref.read(salesHistoryProvider);
    _repository = ref.read(repositoryProvider);
    if (widget.employee != null) {
      fullname = '${widget.employee!.firstName} ${widget.employee!.lastName}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final source = SalesCartData(
        cartList: widget.cartMap.values.toList(), returnItem: _returnItem);
    return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.7,
        minChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildActionButtons(context),
                  const Divider(),
                  Row(
                    children: [
                      _buildSalesCard(),
                      Flexible(child: _buildShoppingCartTable(source))
                    ],
                  ),
                ],
              ),
            ));
  }

  Padding _buildSalesCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        width: 400,
        child: material.Card(
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: ColorManager.grey2),
              borderRadius: BorderRadius.circular(15)),
          child: _buildSalesCardDescription(
              fullname, widget.cartMap.length, widget.sale),
        ),
      ),
    );
  }

  Row _buildActionButtons(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        padding: const EdgeInsets.only(bottom: 8),
        width: AppSize.s40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Button(
            //     child: Text(
            //       'DELETE',
            //       style: TextStyle(color: Colors.red),
            //     ),
            //     onPressed: () {
            //       _showRemoveSaleHistoryDialog(widget.sale);
            //     }),
            IconButton(
                icon: const Icon(FluentIcons.calculator_multiply),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
      const SizedBox(width: 10),
    ]);
  }

  // void _showRemoveSaleHistoryDialog(SalesHistory salesHistory) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return ContentDialog(
  //           title: const Text('Remove Sale History'),
  //           content: Row(
  //             children: const [
  //               Text('Are you sure you want to remove this sale?'),
  //             ],
  //           ),
  //           actions: [
  //             Button(
  //               child: const Text('NO'),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             FilledButton(
  //               child: const Text('YES'),
  //               onPressed: () {
  //                 _salesHistoryDataSource.removeSaleHistory(salesHistory.id);
  //                 Navigator.pop(context);
  //                 Navigator.pop(context);
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }

  Column _buildSalesCardDescription(
      String username, int itemsSold, SalesHistory sale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Sales Rep: $username',
          style: const TextStyle(
              fontWeight: FontWeightManager.semiBold, fontSize: FontSize.s16),
        ),
        Text(
          'Products Sold: $itemsSold',
          style: const TextStyle(fontWeight: FontWeightManager.semiBold),
        ),
        Text(
          'Discount: $kPeso${sale.discount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeightManager.semiBold),
        ),
        Text(
          'Subtotal: $kPeso${sale.subtotal.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeightManager.semiBold),
        ),
        Text(
          'Date: ${dateFormat.format(sale.date)}',
          style: const TextStyle(fontWeight: FontWeightManager.semiBold),
        ),
        Text(
          'Total: $kPeso${numberFormat.format(sale.grandTotal)}',
          style: const TextStyle(
              fontWeight: FontWeightManager.bold, fontSize: FontSize.s25),
        ),
      ],
    );
  }

  material.PaginatedDataTable _buildShoppingCartTable(SalesCartData source) {
    return material.PaginatedDataTable(
        columnSpacing: 30,
        rowsPerPage: 5,
        columns: const [
          material.DataColumn(
              label: Flexible(
            child: Text(
              'NAME',
              style: TextStyle(fontWeight: FontWeightManager.semiBold),
            ),
          )),
          material.DataColumn(
              label: Text(
            'SELLING PRICE',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          material.DataColumn(
              label: Text(
            'COST PRICE',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          material.DataColumn(
              label: Text(
            'QTY',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          material.DataColumn(
              label: Text(
            'TOTAL QTY SOLD',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          material.DataColumn(
              label: Text(
            'CATEGORY',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          )),
          material.DataColumn(
              label: Text(
            '',
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          ))
        ],
        source: source);
  }
}

class SalesCartData extends material.DataTableSource {
  final List<ShoppingCart> cartList;
  final void Function(int id) returnItem;

  SalesCartData({required this.cartList, required this.returnItem});
  @override
  material.DataRow? getRow(int index) {
    final item = cartList[index];
    return material.DataRow.byIndex(index: index, cells: [
      material.DataCell(Text(
        item.product.name.toUpperCase(),
        maxLines: 2,
      )),
      material.DataCell(Text(item.product.sellingPrice.toString())),
      material.DataCell(Text(item.product.costPrice.toString())),
      material.DataCell(Text(item.amount.toString())),
      material.DataCell(Text(item.product.quantitySold.toString())),
      material.DataCell(Text(item.product.category)),
      material.DataCell(FilledButton(
          style: ButtonStyle(backgroundColor: ButtonState.resolveWith(
            (states) {
              if (states.isHovering) {
                return ColorManager.red4;
              }
              return Colors.red;
            },
          )),
          child: const Text('RETURN'),
          onPressed: () {
            returnItem(item.product.id);
          })),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => cartList.length;

  @override
  int get selectedRowCount => 0;
}
