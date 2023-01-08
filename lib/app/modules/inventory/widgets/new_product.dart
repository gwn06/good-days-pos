import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/functions.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/form_product_data.dart';
import 'package:pos_system/app/data/repository/repository.dart';
import 'package:pos_system/app/core/values/extensions.dart';
import 'package:intl/intl.dart';

class NewProduct extends ConsumerStatefulWidget {
  const NewProduct({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewProductState();
}

class _NewProductState extends ConsumerState<NewProduct> {
  final _formKey = GlobalKey<FormState>();
  DateTime expiryDate = DateTime.now();

  var formData = FormProductData(expiryDate: DateTime.now());
  late final Repository _repository;

  @override
  void initState() {
    _repository = ref.read(repositoryProvider);
    super.initState();
  }

  void _submitFormCallback() {
    var currentState = _formKey.currentState;
    if (currentState!.validate()) {
      currentState.save();
      currentState.reset();
      List<String> batchList = [
        ProductBatch(
                amount: formData.availableStock,
                date: formData.expiryDate,
                id: kOne)
            .toJson()
      ];
      final product = ProductInfo(
          name: formData.productName.toTitleCase().trim(),
          expiryDate: expiryDate,
          quantitySold: zero,
          batchList: batchList,
          availableQuantity: formData.availableStock,
          costPrice: formData.costPrice,
          sellingPrice: formData.sellingPrice,
          category: formData.category.toUpperCase().trim(),
          description: formData.description.trim());

      if (_repository.isProductExist(name: product.name)) {
        final oldProduct = _repository.findProduct(name: product.name)!;
        _showUpdateDialog(
            oldProduct: oldProduct,
            newProduct: product,
            updateCallback: () {
              _repository.updateProduct(product: product);
              showTopSnackbar(
                title: AppStrings.success,
                context: context,
                message: AppStrings.updateSuccessful,
                severity: InfoBarSeverity.success,
              );
            });
      } else {
        _repository.addProduct(product);
        showTopSnackbar(
          context: context,
          message: AppStrings.itemAddedSuccess,
          severity: InfoBarSeverity.success,
          title: AppStrings.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: PageHeader(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.newProduct),
              FilledButton(
                  child: const Text('Import Products'),
                  onPressed: () async {
                    try {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['csv'],
                      );

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        final productsString = await file.readAsString();
                        List<List<dynamic>> products =
                            const CsvToListConverter().convert(productsString);
                        List<ProductInfo> parsedProducts = [];
                        for (int i = 1; i < products.length; i++) {
                          final productName = products[i][0] as String;
                          final costPrice = products[i][1].toDouble();
                          final sellingPrice = products[i][2].toDouble();
                          final quantitySold = products[i][3] as int;
                          final availableQuantity = products[i][4] as int;
                          final expiryDate = DateTime.parse(products[i][5]);
                          final category = products[i][6] as String;
                          final description = products[i][7] as String;
                          final newProduct = ProductInfo(
                              quantitySold: quantitySold,
                              availableQuantity: availableQuantity,
                              costPrice: costPrice,
                              sellingPrice: sellingPrice,
                              category: category,
                              name: productName,
                              expiryDate: expiryDate,
                              description: description,
                              batchList: [
                                ProductBatch(
                                        amount: availableQuantity,
                                        date: expiryDate,
                                        id: kOne)
                                    .toJson()
                              ]);
                          parsedProducts.add(newProduct);
                        }
                        _showAcceptNewProductsDialog(parsedProducts);
                      } else {
                        // User canceled the picker
                      }
                    } on FormatException {
                      showTopSnackbar(
                          context: context,
                          message: AppStrings.invalidDateFormat,
                          severity: InfoBarSeverity.error,
                          title: AppStrings.error);
                    } catch (err) {
                      showTopSnackbar(
                          context: context,
                          message: AppStrings.invalidData,
                          severity: InfoBarSeverity.error,
                          title: AppStrings.error);
                    }
                  }),
            ],
          ),
        ),
        content: Container(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            widthFactor: .50,
            child: _buildForm(),
          ),
        ));
  }

  void _showAcceptNewProductsDialog(List<ProductInfo> products) {
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text('Add New Products'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(AppStrings.importErrorMsg),
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
                  _repository.addProducts(products: products);
                  showTopSnackbar(
                      title: AppStrings.success,
                      context: context,
                      message: AppStrings.importedItems,
                      severity: InfoBarSeverity.success);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormBox(
                  header: 'Product Name',
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.length <= kTwo) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    formData = formData.copyWith(productName: value!);
                  },
                ),
              ),
              const SizedBox(width: AppMargin.m12),
              Expanded(
                child: TextFormBox(
                  header: 'Category',
                  initialValue: AppStrings.drug,
                  onSaved: (value) {
                    formData = formData.copyWith(category: value!);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormBox(
                    header: 'Cost Price',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product cost price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      final parsedCostPrice =
                          double.tryParse(value!) ?? zeroDec;
                      formData = formData.copyWith(costPrice: parsedCostPrice);
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                    ]),
              ),
              const SizedBox(width: AppMargin.m12),
              Expanded(
                child: TextFormBox(
                    header: 'Selling Price',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product selling price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      final parsedSellingPrice =
                          double.tryParse(value!) ?? zeroDec;
                      formData =
                          formData.copyWith(sellingPrice: parsedSellingPrice);
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                    ]),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: TextFormBox(
                  header: 'Available Stock',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the stock available';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    final parsedAvailableStock = int.tryParse(value!) ?? zero;
                    formData =
                        formData.copyWith(availableStock: parsedAvailableStock);
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: AppMargin.m12),
              Flexible(
                child: DatePicker(
                    header: 'Expiry Date',
                    selected: expiryDate,
                    onChanged: (value) {
                      setState(() {
                        expiryDate = value;
                      });
                      formData =
                          formData = formData.copyWith(expiryDate: expiryDate);
                    }),
              ),
              const SizedBox(width: AppMargin.m12),
              // Expanded(
              //   child: TextFormBox(
              //     header: 'Expiry Date Alert',
              //   ),
              // ),
            ],
          ),
          TextFormBox(
            header: 'Description',
            onSaved: (value) {
              formData = formData.copyWith(description: value!);
            },
            maxLines: 3,
          ),
          const SizedBox(height: AppMargin.m12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                  child: const Text('Cancel'),
                  onPressed: () {
                    _formKey.currentState!.reset();
                  }),
              const SizedBox(width: AppMargin.m12),
              FilledButton(
                  onPressed: _submitFormCallback, child: const Text('Save')),
            ],
          )
        ],
      ),
    );
  }

  void _showUpdateDialog(
      {required ProductInfo oldProduct,
      required ProductInfo newProduct,
      required Function updateCallback}) {
    final format = DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY);
    showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text(AppStrings.productAlreadyExist),
            constraints: const BoxConstraints(maxWidth: 500),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  oldProduct.name,
                  style: const TextStyle(
                      fontSize: FontSize.s17,
                      fontWeight: FontWeightManager.semiBold),
                ),
                Row(
                  children: [
                    const Text(
                      AppStrings.category,
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                    const SizedBox(width: AppMargin.m12),
                    Text(oldProduct.category),
                    const Text(AppStrings.arrowSign),
                    Text(
                      newProduct.category,
                      style: const TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      AppStrings.sellingPrice,
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                    const SizedBox(width: AppMargin.m12),
                    Text(oldProduct.sellingPrice.toString()),
                    const Text(AppStrings.arrowSign),
                    Text(
                      newProduct.sellingPrice.toString(),
                      style: const TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      AppStrings.costPrice,
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                    const SizedBox(width: AppMargin.m12),
                    Text(oldProduct.costPrice.toString()),
                    const Text(AppStrings.arrowSign),
                    Text(
                      newProduct.costPrice.toString(),
                      style: const TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      AppStrings.availableStock,
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                    const SizedBox(width: AppMargin.m12),
                    Text(oldProduct.availableQuantity.toString()),
                    const Text(AppStrings.arrowSign),
                    Text(
                      newProduct.availableQuantity.toString(),
                      style: const TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      AppStrings.expirationDate,
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                    const SizedBox(width: AppMargin.m12),
                    Text(
                      format.format(oldProduct.expiryDate).toString(),
                    ),
                    const Text(AppStrings.arrowSign),
                    Expanded(
                      child: Text(
                        format.format(newProduct.expiryDate).toString(),
                        style: const TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeightManager.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      AppStrings.description,
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                    const SizedBox(width: AppMargin.m12),
                    Text(oldProduct.description ?? ''),
                    const Text(AppStrings.arrowSign),
                    Text(
                      newProduct.description ?? '',
                      style: const TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Button(
                  child: const Text(AppStrings.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FilledButton(
                  child: const Text(AppStrings.update),
                  onPressed: () {
                    updateCallback();
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}
