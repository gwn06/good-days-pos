import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/internal.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/core/values/functions.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/data_source/local_data_source.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/repository/repository.dart';
import 'package:pos_system/app/global_widgets/search_box.dart';
import 'package:pos_system/app/modules/inventory/widgets/products_data_table.dart';
import 'package:pos_system/objectbox.g.dart';
import 'package:flutter/material.dart' as material;

class BaseInventory extends ConsumerStatefulWidget {
  final FilterBy filterBy;
  final String header;
  const BaseInventory({
    Key? key,
    required this.filterBy,
    required this.header,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BaseInventoryState();
}

class _BaseInventoryState extends ConsumerState<BaseInventory> {
  late final Repository _repository;
  late Stream<List<ProductInfo>> _stream;
  final searchController = TextEditingController();
  final maxQuantityController = TextEditingController(text: k100.toString());
  final _scaffoldKey = GlobalKey<material.ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _repository = ref.read(repositoryProvider);
    _stream = _repository.getFilteredProducts(searchController.text,
        filterBy: widget.filterBy);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data as List<ProductInfo>;
            final count = products.length;

            return ScaffoldPage(
                header: PageHeader(
                    title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${widget.header} (${numberFormatNoDecimal.format(count)})'),
                    FilledButton(
                        child: const Text('Export to CSV'),
                        onPressed: () async {
                          List<List<dynamic>> rows = [];
                          List<dynamic> header = [
                            // "id",
                            "name",
                            "cost price",
                            "selling price",
                            "quantity sold",
                            "quantity available",
                            "expiry date",
                            "category",
                            "description",
                          ];
                          rows.add(header);

                          for (var product in products) {
                            List<dynamic> row = [];
                            // row.add(product.id);
                            row.add(product.name);
                            row.add(product.costPrice);
                            row.add(product.sellingPrice);
                            row.add(product.quantitySold);
                            row.add(product.availableQuantity);
                            row.add(product.expiryDate);
                            row.add(product.category);
                            row.add(product.description);
                            rows.add(row);
                          }

                          String csv = const ListToCsvConverter().convert(rows);
                          String dir = await getFilePath();
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
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        FractionallySizedBox(
                          widthFactor: .75,
                          child: SearchBox(callback: (String query) {
                            int maxRange =
                                int.tryParse(maxQuantityController.text) ??
                                    k100;
                            setState(() {
                              searchController.text = query;
                              _stream = _repository.getFilteredProducts(
                                  searchController.text,
                                  filterBy: widget.filterBy,
                                  maxRange: maxRange);
                            });
                          }),
                        ),
                        if (widget.filterBy == FilterBy.soonOutOfStock) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(
                                      right: AppPadding.p20,
                                      bottom: AppPadding.p5),
                                  width: AppSize.s140,
                                  child: TextBox(
                                    controller: maxQuantityController,
                                    header: 'Max Quantity',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (value) {
                                      int maxRange = int.tryParse(
                                              maxQuantityController.text) ??
                                          k100;
                                      setState(() {
                                        _stream =
                                            _repository.getFilteredProducts(
                                          searchController.text,
                                          filterBy: widget.filterBy,
                                          maxRange: maxRange,
                                        );
                                      });
                                    },
                                  ))
                            ],
                          )
                        ],
                        material.Material(
                          child: ProductsDataTable(
                              scaffoldKey: _scaffoldKey,
                              products: products,
                              onSort: (columnIndex, ascending) {
                                int maxRange =
                                    int.tryParse(maxQuantityController.text) ??
                                        k100;
                                final List<QueryProperty<ProductInfo, dynamic>>
                                    sortFields = [
                                  ProductInfo_.id,
                                  ProductInfo_.name,
                                  ProductInfo_.costPrice,
                                  ProductInfo_.sellingPrice,
                                  ProductInfo_.quantitySold,
                                  ProductInfo_.availableQuantity,
                                  ProductInfo_.expiryDate,
                                  ProductInfo_.category
                                ];
                                setState(() {
                                  _stream = _repository.getFilteredProducts(
                                    searchController.text,
                                    filterBy: widget.filterBy,
                                    sortField: sortFields[columnIndex],
                                    ascending: ascending,
                                    maxRange: maxRange,
                                  );
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                ));
          }
          return const ProgressBar();
        });
  }
}
