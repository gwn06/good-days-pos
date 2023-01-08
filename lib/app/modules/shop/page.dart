import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/utils/sp_helper.dart';
import 'package:pos_system/app/core/values/colors.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/data_source/employees._data_source.dart';
import 'package:pos_system/app/data/enums/discount.dart';
import 'package:pos_system/app/data/enums/product_status.dart';
import 'package:pos_system/app/data/managers/shopping_cart_manager.dart';
import 'package:pos_system/app/data/model/employee.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/repository/repository.dart';
import 'package:pos_system/app/global_widgets/search_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

final discountRadioValueProvider = StateProvider<DiscountType>((ref) {
  return DiscountType.percentage;
});

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  final autoSuggestBox = TextEditingController();
  late final Repository _repository;
  late final ShoppingCartManager _cartManager;
  late final EmployeeDataSource _employeeDataSource;
  late Stream<List<Employee>> _employeeStream;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _repository = ref.read(repositoryProvider);
    _cartManager = ref.read(shoppingCartManagerProvider);
    _employeeDataSource = ref.read(employeeDataSourceProvider);
    _employeeStream = _employeeDataSource.getAllEmployees();
    super.initState();
  }

  void filterProductInventoryCallback(String query) {
    setState(() {
      autoSuggestBox.text = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cartManager.shoppingCart.isNotEmpty) {
      _cartManager.calculateBill();
    }
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.inventoryProducts,
              style: TextStyle(fontWeight: FontWeightManager.bold),
            ),
            StreamBuilder(
              stream: _employeeStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var id = _prefs
                      .then((prefs) => prefs.getInt(selectedEmployeeIdPref));

                  final employees = snapshot.data as List<Employee>;
                  return FutureBuilder(
                      future: id,
                      builder: (context, snapshot) {
                        int selectedId = 1;
                        if (!snapshot.hasData) {
                          Employee? firstEmployee =
                              _employeeDataSource.getFirstEmployee();
                          if (firstEmployee != null) {
                            selectedId = firstEmployee.id;
                            _prefs.then((pref) => pref.setInt(
                                selectedEmployeeIdPref, selectedId));
                          }
                        } else {
                          selectedId = snapshot.data as int;
                        }
                        final selectedEmployee =
                            _employeeDataSource.getEmployee(selectedId);
                        if (employees.isEmpty) return Container();
                        return DropDownButton(
                          leading: const Icon(FluentIcons.switch_user),
                          title: Text(selectedEmployee?.username ?? ''),
                          items: employees
                              .map((employee) => MenuFlyoutItem(
                                  selected: employee.id == selectedId,
                                  text: Text(employee.username),
                                  onPressed: () {
                                    setState(() {
                                      _prefs.then((pref) => pref.setInt(
                                          selectedEmployeeIdPref, employee.id));
                                    });
                                  }))
                              .toList(),
                        );
                      });
                } else {
                  return const ProgressBar();
                }
              },
            )
          ],
        ),
      ),
      content: Row(children: [
        Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBox(callback: filterProductInventoryCallback),
                const SizedBox(height: AppMargin.m20),
                _buildProductList()
              ],
            )),
        const Divider(direction: Axis.vertical),
        Expanded(child: _buildShoppingCounter())
      ]),
    );
  }

  Container _buildShoppingCounter() {
    final isDarkMode = SPHelper.sp.prefs?.getBool(isDarkModeSelected) ?? false;
    return Container(
      color: isDarkMode ? ColorManager.grey5 : ColorManager.yellow1,
      child: Column(
        children: [
          _buildCounterHeader(),
          const Divider(),
          if (_cartManager.shoppingCart.isEmpty)
            Flexible(child: _buildEmptyShoppingCart()),
          if (_cartManager.shoppingCart.isNotEmpty)
            Flexible(child: _buildCounterShoppingList()),
        ],
      ),
    );
  }

  Row _buildCounterHeader() {
    return Row(children: const [
      SizedBox(width: AppMargin.m8),
      Icon(FluentIcons.payment_card),
      SizedBox(width: AppMargin.m8),
      Text(AppStrings.bill,
          style: TextStyle(
            fontSize: FontSize.s20,
            fontWeight: FontWeightManager.semiBold,
          ))
    ]);
  }

  Column _buildCounterShoppingList() {
    return Column(
      children: [
        Flexible(
            flex: 2,
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: _cartManager.shoppingCart.length,
              itemBuilder: (context, index) {
                String key = _cartManager.shoppingCart.keys.elementAt(index);
                final selectedProduct = _cartManager.shoppingCart[key]!.product;
                final sellingPrice = selectedProduct.sellingPrice;
                final originalProduct =
                    _repository.findProduct(id: selectedProduct.id)!;

                return ListTile(
                  // isThreeLine: true,
                  title: Text(
                    selectedProduct.name.toUpperCase(),
                    // maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeightManager.semiBold,
                        fontSize: FontSize.s14),
                  ),
                  subtitle: Text(
                    'Price \u20B1$sellingPrice',
                    style:
                        const TextStyle(fontWeight: FontWeightManager.semiBold),
                  ),
                  trailing: Row(children: [
                    TextButton(
                        child: Text(
                          AppStrings.edit.toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: FontSize.s12,
                          ),
                        ),
                        onPressed: () {
                          _showProductPriceDialog(sellingPrice, key);
                        }),
                    IconButton(
                        icon: const Icon(FluentIcons.calculator_subtract),
                        onPressed: () {
                          setState(() {
                            _cartManager.decreaseProductAmount(key,
                                product: originalProduct);
                          });
                        }),
                    SizedBox(
                        width: 40,
                        child: TextBox(
                          key: Key(key),
                          style: const TextStyle(
                              fontWeight: FontWeightManager.semiBold),
                          placeholder:
                              _cartManager.shoppingCart[key]!.amount.toString(),
                          // controller: TextEditingController(
                          //     text: _cartManager.shoppingCart[key]!.amount
                          //         .toString()),
                          onChanged: (text) {
                            if (text.isEmpty) return;
                            final amount = int.tryParse(text) ?? zero;
                            setState(() {
                              _cartManager.setProductAmount(amount, key,
                                  product: originalProduct);
                            });
                          },
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                        )),
                    IconButton(
                        icon: const Icon(FluentIcons.calculator_addition),
                        onPressed: () {
                          setState(() {
                            _cartManager.increaseProductAmount(key,
                                product: originalProduct);
                          });
                        }),
                    IconButton(
                        icon: Icon(
                          FluentIcons.calculator_multiply,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            // _shoppingCart.remove(key);
                            _cartManager.removeProduct(key);
                          });
                        }),
                  ]),
                );
              },
            )),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: AppPadding.p12),
            child: _buildCounterPaymentInfo(),
          ),
        )
      ],
    );
  }

  Column _buildCounterPaymentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Divider(),
        const SizedBox(height: AppMargin.m8),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.subTotal),
              Text('$kPeso${numberFormat.format(_cartManager.subTotal)}'),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.discount),
              Text('$kPeso${numberFormat.format(_cartManager.discount)}')
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.grandTotal),
              Text(
                '$kPeso${numberFormat.format(_cartManager.grandTotal)}',
                style: TextStyle(
                    fontWeight: FontWeightManager.bold,
                    fontSize: 20,
                    color: Colors.green),
              ),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: AppSize.s14),
        Wrap(
          spacing: AppPadding.p5,
          children: [
            Button(
              onPressed: () {
                setState(() {
                  _cartManager.shoppingCart.clear();
                });
              },
              style: ButtonStyle(
                padding: ButtonState.all(const EdgeInsets.all(AppPadding.p12)),
              ),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(color: Colors.red.light),
              ),
            ),
            Button(
              onPressed: () {
                _showDiscountDialog();
              },
              style: ButtonStyle(
                padding: ButtonState.all(const EdgeInsets.all(AppPadding.p12)),
              ),
              child: Text(
                AppStrings.discount,
                style: TextStyle(color: Colors.blue.light),
              ),
            ),
            FilledButton(
              style: ButtonStyle(
                  padding:
                      ButtonState.all(const EdgeInsets.all(AppPadding.p12)),
                  backgroundColor: ButtonState.resolveWith((states) {
                    if (states.isPressing) {
                      return Colors.green;
                    } else if (states.isHovering) {
                      return Colors.green.light;
                    } else {
                      return Colors.green.lighter;
                    }
                  }),
                  shape: ButtonState.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppSize.s4)),
                  ))),
              onPressed: () {
                _showChargeCounterDialog();
              },
              child: const Text(
                AppStrings.charge,
                style: TextStyle(fontWeight: FontWeightManager.semiBold),
              ),
            ),
          ],
        )
      ],
    );
  }

  Column _buildEmptyShoppingCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(FluentIcons.shopping_cart, size: AppSize.s100, color: Colors.grey),
        SizedBox(
          height: AppPadding.p12,
        ),
        Text(
          'Empty',
          style: TextStyle(
              fontWeight: FontWeightManager.semiBold, fontSize: FontSize.s16),
        ),
      ],
    );
  }

  StreamBuilder _buildProductList() {
    return StreamBuilder<List<ProductInfo>>(
        stream: _repository.getFilteredProducts(autoSuggestBox.text),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data as List<ProductInfo>;
            return _buildProductsGridView(products);
          } else {
            return const ProgressBar();
          }
        });
  }

  ProductStatus _getProductStatus(ProductInfo product) {
    const limit = 15;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day + limit);
    if (product.availableQuantity <= 0) return ProductStatus.outOfStock;
    if (product.expiryDate.isBefore(now)) return ProductStatus.expired;
    if (product.expiryDate.isBefore(today)) return ProductStatus.soonExpire;
    return ProductStatus.valid;
  }

  Color _getProductTint(ProductStatus status) {
    switch (status) {
      case ProductStatus.expired:
        return ColorManager.red5;
      case ProductStatus.outOfStock:
        return ColorManager.grey5;
      case ProductStatus.soonExpire:
        return ColorManager.orange4;
      case ProductStatus.newBatch:
        return ColorManager.green4;
      case ProductStatus.valid:
        return ColorManager.green4;
    }
  }

  Flexible _buildProductsGridView(List<ProductInfo> products) {
    return Flexible(
      child: GridView.builder(
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 70,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final selectedProduct = products[index];
          Color tint = _getProductTint(_getProductStatus(selectedProduct));
          return Tooltip(
            message: '''
${selectedProduct.name.toUpperCase()}
Selling Price $kPeso${selectedProduct.sellingPrice}
Cost Price $kPeso${selectedProduct.costPrice}
Expiry Date: ${dateFormat.format(selectedProduct.expiryDate)}
Description: ${selectedProduct.description}''',
            child: TappableListTile(
              isThreeLine: true,
              leading: Container(
                width: 3,
                height: 55,
                decoration: BoxDecoration(
                    color: tint,
                    borderRadius: const BorderRadius.all(Radius.circular(22))),
              ),
              onTap: () {
                if (selectedProduct.availableQuantity <= 0) {
                  showSnackbar(
                      context,
                      const SizedBox(
                        height: 40,
                        width: 350,
                        child: InfoBar(
                          title: Text('Warning'),
                          severity: InfoBarSeverity.error,
                          content:
                              Text('This product is currently out of stock!'),
                        ),
                      ),
                      alignment: Alignment.topCenter);
                  return;
                }
                if (_cartManager.canAddToCart(selectedProduct.id.toString(),
                    selectedProduct.availableQuantity)) {
                  setState(() {
                    _cartManager.addToCart(selectedProduct.id, selectedProduct);
                  });
                }
              },
              title: Text(
                selectedProduct.name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeightManager.semiBold),
              ),
              subtitle: Text(
                maxLines: 3,
                '${selectedProduct.category}\nPrice \u20B1${selectedProduct.sellingPrice}',
                style: const TextStyle(fontWeight: FontWeightManager.semiBold),
              ),
              trailing: Row(
                children: [
                  const Icon(FluentIcons.stock_up),
                  Text(
                    '${selectedProduct.availableQuantity}',
                  ),
                  const SizedBox(width: AppSize.s12),
                  const Icon(FluentIcons.add),
                ],
              ),
              // backgroundColor: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  void _showChargeCounterDialog() {
    final cashReceivedController = TextEditingController();
    String changeInfo = '';
    double changeAmount = 0;
    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, setChangeState) {
            return ContentDialog(
              title: const Text(AppStrings.charge),
              backgroundDismiss: false,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$kPeso${numberFormat.format(_cartManager.grandTotal)}',
                    style: TextStyle(
                        fontWeight: FontWeightManager.bold,
                        fontSize: FontSize.s25,
                        color: Colors.green.light),
                  ),
                  const SizedBox(height: AppMargin.m8),
                  const Text('Enter Cash Received'),
                  const SizedBox(height: AppMargin.m8),
                  TextBox(
                    controller: cashReceivedController,
                    placeholder: _cartManager.grandTotal.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeightManager.semiBold,
                        fontSize: FontSize.s18),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                    ],
                    onChanged: (value) {
                      double parsedReceivedAmount =
                          double.tryParse(value) ?? zeroDec;
                      setChangeState(() {
                        changeAmount =
                            parsedReceivedAmount - _cartManager.grandTotal;
                        if (changeAmount < zero) {
                          changeInfo = AppStrings.changeShort;
                        } else if (changeAmount == zero) {
                          changeInfo = AppStrings.exactAmount;
                        } else {
                          changeInfo = AppStrings.change;
                        }
                      });
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: AppMargin.m8),
                  Text(
                    '$changeInfo $kPeso${numberFormat.format(changeAmount)}',
                    style: const TextStyle(
                        fontWeight: FontWeightManager.semiBold,
                        fontSize: FontSize.s16),
                  )
                ],
              ),
              actions: [
                Button(
                  child: const Text(AppStrings.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FilledButton(
                  child: const Text(AppStrings.ok),
                  onPressed: () async {
                    await _repository.updateProductsAndAddToSales(
                        cart: _cartManager.shoppingCart,
                        discount: _cartManager.discount,
                        subtotal: _cartManager.subTotal,
                        grandTotal: _cartManager.grandTotal);
                    setState(() {
                      _cartManager.shoppingCart.clear();
                      _cartManager.discount = zeroDec;
                    });
                    if (!mounted) return;
                    showSnackbar(
                        context,
                        const SizedBox(
                          width: 130,
                          height: 40,
                          child: InfoBar(
                            title: Text('SUCCESS!'),
                            severity: InfoBarSeverity.success,
                          ),
                        ),
                        alignment: Alignment.topCenter);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }

  void _showProductPriceDialog(double sellingPrice, String key) {
    double selectedPrice = sellingPrice;
    showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text(AppStrings.sellingPrice),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextBox(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  controller:
                      TextEditingController(text: selectedPrice.toString()),
                  onChanged: (value) {
                    selectedPrice = double.tryParse(value) ?? sellingPrice;
                    setState(() {
                      _cartManager.updateSellingPrice(key, selectedPrice);
                    });
                  },
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              Button(
                child: const Text(AppStrings.cancel),
                onPressed: () {
                  setState(() {
                    _cartManager.updateSellingPrice(key, sellingPrice);
                  });
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: const Text(AppStrings.ok),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _showDiscountDialog() {
    final List<DiscountType> radioButtons = [
      DiscountType.percentage,
      DiscountType.cashAmount
    ];

    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setStateRadio) {
              DiscountType discountType = ref.watch(discountRadioValueProvider);
              return ContentDialog(
                title: const Text(AppStrings.discount),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: AppSize.s12,
                      children: List.generate(
                        radioButtons.length,
                        (index) => RadioButton(
                          checked: discountType == radioButtons[index],
                          onChanged: (value) {
                            setStateRadio(() {
                              if (value) {
                                ref
                                    .read(discountRadioValueProvider.notifier)
                                    .state = radioButtons[index];
                              }
                            });
                          },
                          content: Text(radioButtons[index].displayDiscount),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppMargin.m12),
                    TextBox(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      controller: TextEditingController(
                          text: _cartManager.discount.toString()),
                      onChanged: (value) {
                        final parsedDiscount =
                            double.tryParse(value) ?? zeroDec;
                        setState(() {
                          if (discountType == DiscountType.percentage) {
                            _cartManager.discount =
                                _cartManager.subTotal * (parsedDiscount / k100);
                          } else {
                            _cartManager.discount = parsedDiscount;
                          }
                        });
                      },
                      autofocus: true,
                    ),
                  ],
                ),
                actions: [
                  Button(
                    child: const Text(AppStrings.cancel),
                    onPressed: () {
                      setState(() {
                        _cartManager.discount = zeroDec;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilledButton(
                    child: const Text(AppStrings.ok),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}
