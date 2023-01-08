import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/extensions.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:intl/intl.dart';
import 'package:pos_system/app/data/model/form_product_data.dart';
import 'package:pos_system/app/data/repository/repository.dart';
import 'package:pos_system/app/global_widgets/product_form.dart';
import 'package:pos_system/app/modules/inventory/widgets/stock_batch_form.dart';
import 'package:pos_system/app/modules/inventory/widgets/stock_batch_table.dart';

class ProductsDataTable extends ConsumerStatefulWidget {
  final List<ProductInfo> products;
  final GlobalKey<mat.ScaffoldState> scaffoldKey;
  final void Function(int columnIndex, bool ascending) onSort;
  const ProductsDataTable(
      {Key? key,
      required this.products,
      required this.onSort,
      required this.scaffoldKey})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProductsDataTableState();
}

class _ProductsDataTableState extends ConsumerState<ProductsDataTable> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY);
  late final Repository _repository;
  late final ValueNotifier<int> _productsHash = ValueNotifier(0);

  void _onDataColumnSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort(columnIndex, ascending);
  }

// replaced with riverpod provider
  void onSubmitForm(FormProductData formData) {}

  @override
  void initState() {
    _repository = ref.read(repositoryProvider);
    // _source = ProductsData(widget.products);
    _productsHash.value = widget.products.hashCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productsHash.value = widget.products.hashCode;
    });

    final ProductsData source = ProductsData(
        products: widget.products,
        bottomSheetCallback: _showProductBottomSheet);
    return mat.PaginatedDataTable(
      source: source,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
      rowsPerPage: 8,
      columns: [
        mat.DataColumn(
          label: const Text(
            AppStrings.id,
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: Text(
            AppStrings.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: Text(
            AppStrings.costPrice.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          numeric: true,
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: Text(
            AppStrings.sellingPrice.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          numeric: true,
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: const Text(
            AppStrings.qtySold,
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          numeric: true,
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: const Text(
            AppStrings.qtyAvail,
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          numeric: true,
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: const Text(
            AppStrings.expiryDate,
            style: TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          onSort: _onDataColumnSort,
        ),
        mat.DataColumn(
          label: Text(
            AppStrings.category.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeightManager.semiBold),
          ),
          onSort: _onDataColumnSort,
        ),
      ],
    );
  }

  void _showDeleteProductDialog(ProductInfo product) {
    final productName = product.name;
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text('Delete Product'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to remove'),
                Text(
                  '$productName?',
                  style: const TextStyle(fontWeight: FontWeightManager.bold),
                ),
              ],
            ),
            actions: [
              Button(
                child: const Text('NO'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: const Text('YES'),
                onPressed: () {
                  _repository.deleteProduct(product.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _showProductBottomSheet({required int index}) {
    showBottomSheet(
      context: context,
      builder: (context) {
        bool formFieldsEnabled = false;
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(builder: (context, setSheetState) {
          return ValueListenableBuilder(
              valueListenable: _productsHash,
              builder: (context, value, child) {
                if (widget.products.isEmpty) {
                  Navigator.pop(context);
                  return Container();
                }
                ProductInfo? product;
                try {
                  product = widget.products[index];
                } on RangeError {
                  product = widget.products[zero];
                  Navigator.pop(context);
                  return Container();
                }
                return BottomSheet(
                  showHandle: false,
                  initialChildSize: 0.8,
                  header: Column(children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                            child: Text(
                              'DELETE',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              _showDeleteProductDialog(product!);
                            }),
                        const SizedBox(width: AppMargin.m12),
                        FilledButton(
                            child: formFieldsEnabled
                                ? const Text('SAVE')
                                : const Text('EDIT'),
                            onPressed: () {
                              setSheetState(() {
                                formFieldsEnabled = !formFieldsEnabled;
                                if (!formFieldsEnabled) {
                                  var currentState = formKey.currentState;
                                  if (currentState!.validate()) {
                                    currentState.save();
                                    final formData = ref
                                        .watch(formDataProvider.notifier)
                                        .state;
                                    final updatedProduct = product!.copyWith(
                                        name: formData.productName
                                            .toUpperCase()
                                            .trim(),
                                        expiryDate: formData.expiryDate,
                                        availableQuantity:
                                            formData.availableStock,
                                        costPrice: formData.costPrice,
                                        sellingPrice: formData.sellingPrice,
                                        category: formData.category
                                            .toUpperCase()
                                            .trim(),
                                        description:
                                            formData.description.trim());
                                    _repository.updateProduct(
                                        id: product.id,
                                        product: updatedProduct);
                                  }
                                }
                              });
                            }),
                        const SizedBox(width: AppMargin.m12),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(FluentIcons.calculator_multiply)),
                        const SizedBox(width: AppMargin.m16),
                      ],
                    ),
                    const SizedBox(height: AppMargin.m8),
                  ]),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeightManager.bold,
                                      fontSize: FontSize.s25),
                                ),
                                const SizedBox(height: AppMargin.m18),
                                ProductForm(
                                  setState: setSheetState,
                                  formKey: formKey,
                                  hasSaveCancelButtons: false,
                                  hasInitialValues: true,
                                  showQuantitySold: true,
                                  enabled: formFieldsEnabled,
                                  product: product,
                                  onsubmit: onSubmitForm,
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: 0.5,
                                  child: StockBatchForm(
                                    product: product,
                                    setSheetState: setSheetState,
                                  ),
                                ),
                                // SizedBox(width: 50),
                                FractionallySizedBox(
                                  widthFactor: 1,
                                  child: StockBatchTable(
                                    product: product,
                                    setSheetState: setSheetState,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ], // description: Text('Description or Details here'),
                );
              });
        });
      },
    );
  }
}

class ProductsData extends mat.DataTableSource {
  final List<ProductInfo> products;
  final void Function({required int index}) bottomSheetCallback;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY);

  ProductsData({required this.products, required this.bottomSheetCallback});
  @override
  mat.DataRow getRow(int index) {
    final product = products[index];
    final productExpired = isProductExpired(product.expiryDate);
    return mat.DataRow.byIndex(index: index, cells: [
      mat.DataCell(
          Text(
            products[index].id.toString(),
          ), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(
          Text(
            product.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeightManager.medium),
          ), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(Text('$kPeso${product.costPrice.toString()}'), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(Text('$kPeso${product.sellingPrice.toString()}'), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(Text(product.quantitySold.toString()), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(Text(product.availableQuantity.toString()), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(
          Text(
            dateFormat.format(product.expiryDate),
            style: TextStyle(color: productExpired ? Colors.red : null),
          ), onTap: () {
        bottomSheetCallback(index: index);
      }),
      mat.DataCell(Text(product.category), onTap: () {
        bottomSheetCallback(index: index);
      }),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;

  bool isProductExpired(DateTime expiryDate) {
    final currentDate = DateTime.now();
    return expiryDate.isBefore(currentDate);
  }
}
