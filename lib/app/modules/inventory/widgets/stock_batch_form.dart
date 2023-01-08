import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/managers/product_batch_manager.dart';
import 'package:pos_system/app/data/model/form_product_data.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/repository/repository.dart';

class StockBatchForm extends ConsumerStatefulWidget {
  final void Function(void Function()) setSheetState;
  final ProductInfo product;
  const StockBatchForm({
    Key? key,
    required this.product,
    required this.setSheetState,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockBatchFormState();
}

class _StockBatchFormState extends ConsumerState<StockBatchForm> {
  DateTime expiryDate = DateTime.now();
  FormProductBatch formProductBatch = FormProductBatch.empty();
  final ProductBatchManager _batchManager = ProductBatchManagerImpl();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            const Text(
              'Add Stock Batch',
              style: TextStyle(
                  fontWeight: FontWeightManager.bold, fontSize: FontSize.s18),
            ),
            SizedBox(
              // width: AppSize.s220,
              child: TextFormBox(
                header: 'Quantity',
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of stock';
                  }
                  return null;
                },
                onSaved: (amountStr) {
                  final amount = int.tryParse(amountStr!) ?? 0;
                  formProductBatch = formProductBatch.copyWith(amount: amount);
                },
              ),
            ),
            SizedBox(
                // width: AppSize.s220,
                child: DatePicker(
              header: 'Expiry Date',
              selected: expiryDate,
              onChanged: (date) {
                setState(() {
                  expiryDate = date;
                });
              },
            )),
            const SizedBox(height: AppSize.s18),
            FilledButton(
                child: const Text('Add Stock'),
                onPressed: () {
                  final currentState = formKey.currentState;
                  if (currentState!.validate()) {
                    currentState.save();
                    final batchListJson = widget.product.batchList;
                    final batchList = batchListJson
                        .map((batch) => ProductBatch.fromJson(batch))
                        .toList();
                    final id = _batchManager.getNewBatchId(batchList);
                    final newProductBatch = ProductBatch(
                        amount: formProductBatch.amount,
                        date: expiryDate,
                        id: id);
                    // batchListJson.add(newProductBatch.toJson());
                    batchList.add(newProductBatch);
                    final totalStock =
                        _batchManager.calculateAvailableStock(batchList);
                    final minExpiryDate =
                        _batchManager.getMinExpiryDate(batchList);
                    final batchListJsonUpdated =
                        batchList.map((batch) => batch.toJson()).toList();
                    final updatedProduct = widget.product.copyWith(
                      id: widget.product.id,
                      batchList: batchListJsonUpdated,
                      availableQuantity: totalStock,
                      expiryDate: minExpiryDate,
                    );
                    final repository = ref.watch(repositoryProvider);
                    repository.updateProduct(product: updatedProduct);
                    currentState.reset();
                    widget.setSheetState.call(() {});
                  }
                })
          ],
        ));
  }
}
