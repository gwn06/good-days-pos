import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' as mat;
import 'package:pos_system/app/core/values/colors.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/data/managers/product_batch_manager.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/repository/repository.dart';

class StockBatchTable extends ConsumerStatefulWidget {
  final ProductInfo product;
  final void Function(void Function()) setSheetState;
  const StockBatchTable({
    Key? key,
    required this.product,
    required this.setSheetState,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StockBatchTableState();
}

class _StockBatchTableState extends ConsumerState<StockBatchTable> {
  void updateBatchList() {}
  final ProductBatchManager _batchManager = ProductBatchManagerImpl();
  late final Repository _repository;

  @override
  void initState() {
    _repository = ref.read(repositoryProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> batchListJson = widget.product.batchList;

    final source = BatchData(
        batchList: batchListJson,
        removeFromBatchList: ({required int index}) {
          batchListJson.removeAt(index);
          final batchList = batchListJson
              .map((batch) => ProductBatch.fromJson(batch))
              .toList();
          final availableStock =
              _batchManager.calculateAvailableStock(batchList);
          final minExpiryDate = _batchManager.getMinExpiryDate(batchList);
          final updatedProduct = widget.product.copyWith(
              batchList: batchListJson,
              availableQuantity: availableStock,
              expiryDate: minExpiryDate);
          _repository.updateProduct(
              id: widget.product.id, product: updatedProduct);
          // Navigator.pop(context);
          widget.setSheetState.call(() {});
        });
    return mat.PaginatedDataTable(
      rowsPerPage: 4,
      columns: const [
        mat.DataColumn(label: Text('Batch ID')),
        mat.DataColumn(label: Text('Quantity'), numeric: true),
        mat.DataColumn(label: Text('Expiry Date')),
        mat.DataColumn(label: Text('')),
      ],
      source: source,
    );
  }
}

class BatchData extends mat.DataTableSource {
  final List<String> batchList;
  final void Function({required int index}) removeFromBatchList;

  BatchData({required this.batchList, required this.removeFromBatchList});
  @override
  mat.DataRow? getRow(int index) {
    final batchString = batchList[index];
    final batch = ProductBatch.fromJson(batchString);
    return mat.DataRow.byIndex(index: index, cells: [
      mat.DataCell(Text(batch.id.toString())),
      mat.DataCell(Text(batch.amount.toString())),
      mat.DataCell(Text(dateFormat.format(batch.date))),
      mat.DataCell(FilledButton(
          style: ButtonStyle(backgroundColor: ButtonState.resolveWith(
            (states) {
              if (states.isHovering) {
                return ColorManager.red4;
              }
              return Colors.red;
            },
          )),
          child: const Text('Delete'),
          onPressed: () {
            removeFromBatchList(index: index);
          })),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => batchList.length;

  @override
  int get selectedRowCount => 0;
}
