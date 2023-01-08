import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/formats.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/form_product_data.dart';
import 'package:intl/intl.dart';

final formDataProvider = StateProvider(
  (ref) => FormProductData(expiryDate: DateTime.now()),
);

class ProductForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final bool hasSaveCancelButtons;
  final void Function(void Function()) setState;
  final bool hasInitialValues;
  final bool enabled;
  final bool showQuantitySold;
  final ProductInfo product;
  final void Function(FormProductData formData) onsubmit;
  const ProductForm({
    Key? key,
    required this.formKey,
    required this.setState,
    this.hasSaveCancelButtons = true,
    this.hasInitialValues = false,
    required this.product,
    this.enabled = false,
    this.showQuantitySold = false,
    required this.onsubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildForm(product: product, ref: ref);
  }

  Form _buildForm({
    required ProductInfo product,
    required WidgetRef ref,
  }) {
    final FormProductData formData =
        FormProductData(expiryDate: product.expiryDate);
    DateTime expiryDate = product.expiryDate;
    ref
        .read(formDataProvider.notifier)
        .update((state) => state.copyWith(expiryDate: product.expiryDate));
    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormBox(
                  key: ObjectKey(product.name),
                  header: 'Product Name',
                  enabled: enabled,
                  initialValue:
                      hasInitialValues ? product.name.toUpperCase() : null,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.length <= kTwo) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // formData = formData.copyWith(productName: value!);
                    ref
                        .read(formDataProvider.notifier)
                        .update((state) => state.copyWith(productName: value!));
                  },
                ),
              ),
              const SizedBox(width: AppMargin.m12),
              Expanded(
                child: TextFormBox(
                  header: 'Category',
                  enabled: enabled,
                  textCapitalization: TextCapitalization.characters,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
                  // ],
                  initialValue: hasInitialValues ? product.category : null,
                  onSaved: (value) {
                    // formData = formData.copyWith(category: value!);
                    ref
                        .read(formDataProvider.notifier)
                        .update((state) => state.copyWith(category: value!));
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
                    enabled: enabled,
                    initialValue:
                        hasInitialValues ? product.costPrice.toString() : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product cost price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      final parsedCostPrice =
                          double.tryParse(value!) ?? zeroDec;
                      // formData = formData.copyWith(costPrice: parsedCostPrice);
                      ref.read(formDataProvider.notifier).update((state) =>
                          state.copyWith(costPrice: parsedCostPrice));
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
                    enabled: enabled,
                    initialValue: hasInitialValues
                        ? product.sellingPrice.toString()
                        : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product selling price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      final parsedSellingPrice =
                          double.tryParse(value!) ?? zeroDec;
                      // formData =
                      //     formData.copyWith(sellingPrice: parsedSellingPrice);
                      ref.read(formDataProvider.notifier).update((state) =>
                          state.copyWith(sellingPrice: parsedSellingPrice));
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
              Expanded(
                child: TextFormBox(
                  key: ObjectKey(product.availableQuantity),
                  header: 'Available Stock',
                  enabled: false,
                  initialValue: hasInitialValues
                      ? product.availableQuantity.toString()
                      : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the stock available';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    final parsedAvailableStock = int.tryParse(value!) ?? zero;
                    // formData =
                    //     formData.copyWith(availableStock: parsedAvailableStock);
                    ref.read(formDataProvider.notifier).update((state) =>
                        state.copyWith(availableStock: parsedAvailableStock));
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: AppMargin.m12),
              if (showQuantitySold)
                Expanded(
                  child: TextFormBox(
                    header: 'Quantity Sold',
                    enabled: false,
                    initialValue: hasInitialValues
                        ? product.quantitySold.toString()
                        : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quantity sold';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      final parsedQuantitySold = int.tryParse(value!) ?? zero;
                      // formData =
                      //     formData.copyWith(quantitySold: parsedQuantitySold);
                      ref.read(formDataProvider.notifier).update((state) =>
                          state.copyWith(quantitySold: parsedQuantitySold));
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              Expanded(
                child:
                    // ? DatePicker(
                    //     key: ObjectKey(expiryDate),
                    //     header: 'Expiry Date',
                    //     selected: expiryDate,
                    //     onChanged: (value) {
                    //       setState(() {
                    //         expiryDate = value;
                    //       });
                    //       // formData = formData =
                    //       //     formData.copyWith(expiryDate: expiryDate);
                    //       ref.read(formDataProvider.notifier).update((state) =>
                    //           state.copyWith(expiryDate: expiryDate));
                    //     })
                    TextFormBox(
                        key: ObjectKey(expiryDate),
                        header: 'Expiry Date',
                        enabled: false,
                        initialValue: dateFormat.format(expiryDate)),
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
            enabled: enabled,
            initialValue: hasInitialValues ? product.description : null,
            onSaved: (value) {
              // formData = formData.copyWith(description: value!);
              ref
                  .read(formDataProvider.notifier)
                  .update((state) => state.copyWith(description: value!));
            },
            maxLines: 3,
          ),
          const SizedBox(height: AppMargin.m12),
          if (hasSaveCancelButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                    child: const Text('Cancel'),
                    onPressed: () {
                      formKey.currentState!.reset();
                    }),
                const SizedBox(width: AppMargin.m12),
                FilledButton(
                    child: const Text('Save'),
                    onPressed: () {
                      onsubmit(formData);
                    }),
              ],
            )
        ],
      ),
    );
  }
}

// class ProductForm extends ConsumerStatefulWidget {
//   final GlobalKey<FormState> formKey;
//   final bool hasSaveCancelButtons;
//   final bool hasInitialValues;
//   final bool enabled;
//   final bool showQuantitySold;
//   final ProductInfo product;
//   final void Function(FormProductData formData) onsubmit;
//   const ProductForm({
//     Key? key,
//     required this.formKey,
//     this.hasSaveCancelButtons = true,
//     this.hasInitialValues = false,
//     required this.product,
//     this.enabled = false,
//     this.showQuantitySold = false,
//     required this.onsubmit,
//   }) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ProductFormState();
// }

// class _ProductFormState extends ConsumerState<ProductForm> {
//   late DateTime expiryDate;

//   late final FormProductData formData;

//   @override
//   void initState() {
//     expiryDate = widget.product.expiryDate;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _buildForm(product: widget.product);
//   }

//   Form _buildForm({required ProductInfo product}) {
//     return Form(
//       key: widget.formKey,
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: TextFormBox(
//                   header: 'Product Name',
//                   enabled: widget.enabled,
//                   initialValue: widget.hasInitialValues ? product.name : null,
//                   validator: (value) {
//                     if (value == null ||
//                         value.isEmpty ||
//                         value.length <= kTwo) {
//                       return 'Please enter the product name';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     // formData = formData.copyWith(productName: value!);
//                     ref
//                         .read(formDataProvider.notifier)
//                         .update((state) => state.copyWith(productName: value!));
//                   },
//                 ),
//               ),
//               const SizedBox(width: AppMargin.m12),
//               Expanded(
//                 child: TextFormBox(
//                   header: 'Category',
//                   enabled: widget.enabled,
//                   textCapitalization: TextCapitalization.characters,
//                   // inputFormatters: [
//                   //   FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
//                   // ],
//                   initialValue:
//                       widget.hasInitialValues ? product.category : null,
//                   onSaved: (value) {
//                     // formData = formData.copyWith(category: value!);
//                     ref
//                         .read(formDataProvider.notifier)
//                         .update((state) => state.copyWith(category: value!));
//                   },
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormBox(
//                     header: 'Cost Price',
//                     enabled: widget.enabled,
//                     initialValue: widget.hasInitialValues
//                         ? product.costPrice.toString()
//                         : null,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter the product cost price';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       final parsedCostPrice =
//                           double.tryParse(value!) ?? zeroDec;
//                       // formData = formData.copyWith(costPrice: parsedCostPrice);
//                       ref.read(formDataProvider.notifier).update((state) =>
//                           state.copyWith(costPrice: parsedCostPrice));
//                     },
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                     inputFormatters: [
//                       FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
//                     ]),
//               ),
//               const SizedBox(width: AppMargin.m12),
//               Expanded(
//                 child: TextFormBox(
//                     header: 'Selling Price',
//                     enabled: widget.enabled,
//                     initialValue: widget.hasInitialValues
//                         ? product.sellingPrice.toString()
//                         : null,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter the product selling price';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       final parsedSellingPrice =
//                           double.tryParse(value!) ?? zeroDec;
//                       // formData =
//                       //     formData.copyWith(sellingPrice: parsedSellingPrice);
//                       ref.read(formDataProvider.notifier).update((state) =>
//                           state.copyWith(sellingPrice: parsedSellingPrice));
//                     },
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                     inputFormatters: [
//                       FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
//                     ]),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormBox(
//                   header: 'Available Stock',
//                   enabled: widget.enabled,
//                   initialValue: widget.hasInitialValues
//                       ? product.availableQuantity.toString()
//                       : null,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter the stock available';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     final parsedAvailableStock = int.tryParse(value!) ?? zero;
//                     // formData =
//                     //     formData.copyWith(availableStock: parsedAvailableStock);
//                     ref.read(formDataProvider.notifier).update((state) =>
//                         state.copyWith(availableStock: parsedAvailableStock));
//                   },
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 ),
//               ),
//               const SizedBox(width: AppMargin.m12),
//               if (widget.showQuantitySold)
//                 Expanded(
//                   child: TextFormBox(
//                     header: 'Quantity Sold',
//                     enabled: false,
//                     initialValue: widget.hasInitialValues
//                         ? product.quantitySold.toString()
//                         : null,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter the quantity sold';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       final parsedQuantitySold = int.tryParse(value!) ?? zero;
//                       // formData =
//                       //     formData.copyWith(quantitySold: parsedQuantitySold);
//                       ref.read(formDataProvider.notifier).update((state) =>
//                           state.copyWith(quantitySold: parsedQuantitySold));
//                     },
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   ),
//                 ),
//               Expanded(
//                 child: widget.enabled
//                     ? DatePicker(
//                         header: 'Expiry Date',
//                         selected: expiryDate,
//                         onChanged: (value) {
//                           setState(() {
//                             expiryDate = value;
//                           });
//                           // formData = formData =
//                           //     formData.copyWith(expiryDate: expiryDate);
//                           ref.read(formDataProvider.notifier).update((state) =>
//                               state.copyWith(expiryDate: expiryDate));
//                         })
//                     : TextFormBox(
//                         header: 'Expiry Date',
//                         enabled: widget.enabled,
//                         initialValue: dateFormat.format(expiryDate)),
//               ),
//               const SizedBox(width: AppMargin.m12),
//               // Expanded(
//               //   child: TextFormBox(
//               //     header: 'Expiry Date Alert',
//               //   ),
//               // ),
//             ],
//           ),
//           TextFormBox(
//             header: 'Description',
//             enabled: widget.enabled,
//             initialValue: widget.hasInitialValues ? product.description : null,
//             onSaved: (value) {
//               // formData = formData.copyWith(description: value!);
//               ref
//                   .read(formDataProvider.notifier)
//                   .update((state) => state.copyWith(description: value!));
//             },
//             maxLines: 3,
//           ),
//           const SizedBox(height: AppMargin.m12),
//           if (widget.hasSaveCancelButtons)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Button(
//                     child: const Text('Cancel'),
//                     onPressed: () {
//                       widget.formKey.currentState!.reset();
//                     }),
//                 const SizedBox(width: AppMargin.m12),
//                 FilledButton(
//                     child: const Text('Save'),
//                     onPressed: () {
//                       widget.onsubmit(formData);
//                     }),
//               ],
//             )
//         ],
//       ),
//     );
//   }
// }
