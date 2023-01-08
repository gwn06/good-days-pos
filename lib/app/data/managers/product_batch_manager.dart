import 'dart:math';

import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/data/model/product.dart';

abstract class ProductBatchManager {
  int calculateAvailableStock(List<ProductBatch> batchList);
  DateTime getMinExpiryDate(List<ProductBatch> batchList);
  int getNewBatchId(List<ProductBatch> batchList);
  List<ProductBatch> getReducedProductBatch(
      {required List<ProductBatch> batchList, required int amount});
  List<ProductBatch> getIncreasedProductBatch(
      {required List<ProductBatch> batchList,
      required List<ProductBatch> toReturn});
  List<ProductBatch> updateCartBatchAmount(
      {required List<ProductBatch> cartBatchList,
      required List<ProductBatch> productBatchList,
      required int amount});
}

class ProductBatchManagerImpl implements ProductBatchManager {
  @override
  int calculateAvailableStock(List<ProductBatch> batchList) {
    int availableStock = 0;
    for (var batch in batchList) {
      availableStock += batch.amount;
    }
    return availableStock;
  }

  @override
  int getNewBatchId(List<ProductBatch> batchList) {
    int id = kOne;
    if (batchList.length >= kOne) {
      final batch = batchList.last;
      id = batch.id + kOne;
    }
    return id;
  }

  @override
  DateTime getMinExpiryDate(List<ProductBatch> batchList) {
    if (batchList.length <= zero) return DateTime.now();
    batchList.sort((a, b) => a.date.compareTo(b.date));
    return batchList.first.date;
  }

  @override
  List<ProductBatch> getReducedProductBatch(
      {required List<ProductBatch> batchList, required int amount}) {
    if (batchList.isEmpty) return [];
    List<ProductBatch> newBatchList = [];
    int remainingAmount = amount;
    for (final batch in batchList) {
      final remainingStock = batch.amount - remainingAmount;
      final maxRemainingStock = max(remainingStock, zero);
      if (maxRemainingStock == zero) {
        remainingAmount -= batch.amount;
      } else {
        newBatchList.add(batch.copyWith(amount: remainingStock));
        remainingAmount = zero;
      }
    }
    return newBatchList;
  }

  @override
  List<ProductBatch> getIncreasedProductBatch(
      {required List<ProductBatch> batchList,
      required List<ProductBatch> toReturn}) {
    for (var batch in toReturn) {
      final batchIndex =
          batchList.indexWhere((element) => element.id == batch.id);
      if (batchIndex == kNegativeOne) {
        batchList.add(batch);
        continue;
      }
      final selectedIndex =
          batchList.indexWhere((batchElem) => batchElem.id == batch.id);
      final selectedBatch = batchList[selectedIndex];
      batchList[selectedIndex] =
          selectedBatch.copyWith(amount: selectedBatch.amount + batch.amount);
    }
    batchList.sort((a, b) => a.id.compareTo(b.id));
    return batchList;
  }

  @override
  List<ProductBatch> updateCartBatchAmount(
      {required List<ProductBatch> cartBatchList,
      required List<ProductBatch> productBatchList,
      required int amount}) {
    int remainingAmount = amount;
    for (int i = 0; i < productBatchList.length; i++) {
      if (cartBatchList.length == i) break;
      final cartBatch = cartBatchList[i];

      var productBatchAmount = productBatchList[i].amount;
      if (productBatchAmount > cartBatch.amount && amount == kOne) {
        cartBatchList[i] =
            cartBatch.copyWith(amount: cartBatch.amount + amount);
        remainingAmount -= kOne;
      } else if (remainingAmount >= kOne &&
          productBatchAmount > remainingAmount) {
        cartBatchList[i] = cartBatch.copyWith(amount: remainingAmount);
        remainingAmount = zero;
      } else if (remainingAmount > kOne &&
          productBatchAmount <= remainingAmount) {
        cartBatchList[i] = cartBatch.copyWith(amount: productBatchAmount);
        remainingAmount -= productBatchAmount;
      }
      if (cartBatchList.length == i + kOne && remainingAmount > zero) {
        if (productBatchList.length <= i + kOne) break;
        cartBatchList.add(productBatchList[i + kOne].copyWith(amount: zero));
      }
    }

    return cartBatchList;
  }
}
