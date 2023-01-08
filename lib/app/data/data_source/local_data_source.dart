import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/internal.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/data/data_source/objectbox_database.dart';
import 'package:pos_system/app/data/managers/product_batch_manager.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/main.dart';
import 'package:pos_system/objectbox.g.dart';

const path = 'products_db';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSourceImpl(objectBox);
});

enum FilterBy {
  outOfStock,
  soonToExpire,
  soonOutOfStock,
  expired,
  query,
  none,
}

abstract class LocalDataSource {
  Stream<List<ProductInfo>> getAllProducts();
  Stream<List<ProductInfo>> getFilteredProducts(
    String query, {
    FilterBy filterBy,
    QueryProperty<ProductInfo, dynamic>? sortField,
    bool ascending,
    int minRange,
    int maxRange,
  });
  ProductInfo? findProduct({int? id, String? name});
  bool isProductExist({int? id, String? name});
  void addProduct(ProductInfo product);
  void addProducts({required List<ProductInfo> products});
  void deleteProduct(int id);
  void deleteAllProducts();
  void updateProduct({int? id, required ProductInfo product});
  void updateProducts({required Map<String, ShoppingCart> cart});
  Stream<List<ProductInfo>> sortProducts(
      QueryProperty<ProductInfo, dynamic> sortField, bool ascending);
}

class LocalDataSourceImpl implements LocalDataSource {
  final ObjectBoxDatabase db;
  final ProductBatchManager _productBatchManager = ProductBatchManagerImpl();

  LocalDataSourceImpl(this.db);

  @override
  void addProduct(ProductInfo product) {
    db.productBox.put(product);
  }

  @override
  void addProducts({required List<ProductInfo> products}) {
    db.productBox.putMany(products);
  }

  @override
  void deleteProduct(int id) {
    final result = db.productBox.remove(id);
  }

  @override
  void deleteAllProducts() {
    db.productBox.removeAll();
  }

  @override
  Stream<List<ProductInfo>> getFilteredProducts(
    String query, {
    FilterBy filterBy = FilterBy.query,
    QueryProperty<ProductInfo, dynamic>? sortField,
    bool ascending = true,
    int minRange = kOne,
    int maxRange = k100,
  }) {
    if (query.isEmpty && FilterBy.none == filterBy) {
      return getAllProducts();
    }

    sortField ??= ProductInfo_.name;
    final today = DateTime.now();
    const daysCheckExpiration = Duration(days: 15);
    switch (filterBy) {
      case FilterBy.query:
        final qBuilder = db.productBox.query(ProductInfo_.name
            .contains(query, caseSensitive: false)
            .or(ProductInfo_.category.contains(query, caseSensitive: false))
            .or(ProductInfo_.description.contains(query, caseSensitive: false)))
          ..order(sortField, flags: ascending ? 0 : Order.descending);
        return qBuilder
            .watch(triggerImmediately: true)
            .map((query) => query.find());
      case FilterBy.soonOutOfStock:
        final qBuilder = db.productBox.query(ProductInfo_.name
            .contains(query, caseSensitive: false)
            .and(ProductInfo_.availableQuantity.lessOrEqual(maxRange))
            .and(ProductInfo_.availableQuantity.greaterOrEqual(minRange)))
          ..order(sortField, flags: ascending ? 0 : Order.descending);
        return qBuilder
            .watch(triggerImmediately: true)
            .map((query) => query.find());
      case FilterBy.outOfStock:
        final qBuilder = db.productBox.query(ProductInfo_.name
            .contains(query, caseSensitive: false)
            .and(ProductInfo_.availableQuantity.lessThan(kOne)))
          ..order(sortField, flags: ascending ? 0 : Order.descending);
        return qBuilder
            .watch(triggerImmediately: true)
            .map((query) => query.find());
      case FilterBy.soonToExpire:
        final qBuilder = db.productBox.query(ProductInfo_.name
            .contains(query, caseSensitive: false)
            .and(ProductInfo_.expiryDate.between(today.millisecondsSinceEpoch,
                today.add(daysCheckExpiration).millisecondsSinceEpoch)))
          ..order(sortField, flags: ascending ? 0 : Order.descending);
        return qBuilder
            .watch(triggerImmediately: true)
            .map((query) => query.find());
      case FilterBy.expired:
        final qBuilder = db.productBox.query(ProductInfo_.name
            .contains(query, caseSensitive: false)
            .and(ProductInfo_.expiryDate
                .lessOrEqual(today.millisecondsSinceEpoch)))
          ..order(sortField, flags: ascending ? 0 : Order.descending);
        return qBuilder
            .watch(triggerImmediately: true)
            .map((query) => query.find());
      default:
        return getAllProducts();
    }
  }

  @override
  Stream<List<ProductInfo>> getAllProducts() {
    final products = db.productBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
    return products;
  }

  @override
  void updateProduct({int? id, required ProductInfo product}) {
    if (id != null) {
      final oldProduct = db.productBox.get(id);
      if (oldProduct == null) return;
      final updatedProduct = oldProduct.copyWith(
          name: product.name,
          category: product.category,
          quantitySold: product.quantitySold,
          availableQuantity: product.availableQuantity,
          costPrice: product.costPrice,
          sellingPrice: product.sellingPrice,
          batchList: product.batchList,
          description: product.description,
          expiryDate: product.expiryDate);
      db.productBox.put(updatedProduct, mode: PutMode.update);
    } else {
      final productFound = findProduct(name: product.name);
      if (productFound == null) return;
      final updatedProduct = productFound.copyWith(
          batchList: product.batchList,
          category: product.category,
          availableQuantity: product.availableQuantity,
          quantitySold: product.quantitySold,
          costPrice: product.costPrice,
          sellingPrice: product.sellingPrice,
          description: product.description,
          expiryDate: product.expiryDate);
      db.productBox.put(updatedProduct, mode: PutMode.update);
    }
  }

  @override
  void updateProducts({required Map<String, ShoppingCart> cart}) {
    final List<ProductInfo> products = [];
    for (var productValue in cart.values) {
      final product = productValue.product;
      final oldProduct = findProduct(id: product.id)!;
      final batchList = oldProduct.batchList
          .map((batch) => ProductBatch.fromJson(batch))
          .toList();
      final newBatch = _productBatchManager.getReducedProductBatch(
          batchList: batchList, amount: productValue.amount);
      final availableQuantity =
          _productBatchManager.calculateAvailableStock(newBatch);
      // final updatedProduct = product.copyWith(
      //     availableQuantity: product.availableQuantity - productValue.amount,
      //     quantitySold: product.quantitySold + productValue.amount);
      final updatedProduct = product.copyWith(
          availableQuantity: availableQuantity,
          batchList: newBatch.map((batch) => batch.toJson()).toList(),
          quantitySold: product.quantitySold + productValue.amount);
      products.add(updatedProduct);
    }

    db.productBox.putMany(products, mode: PutMode.update);
  }

  @override
  ProductInfo? findProduct({int? id, String? name}) {
    if (id != null) {
      return db.productBox.get(id);
    } else if (name != null) {
      final query = db.productBox
          .query(ProductInfo_.name.equals(name, caseSensitive: false))
          .build();
      return query.findFirst();
    }
    return null;
  }

  @override
  bool isProductExist({int? id, String? name}) {
    final product = findProduct(id: id, name: name);
    if (product == null) return false;
    return true;
  }

  @override
  Stream<List<ProductInfo>> sortProducts(
      QueryProperty<ProductInfo, dynamic> sortField, bool ascending) {
    final qBuilder = db.productBox.query()
      ..order(sortField, flags: ascending ? 0 : Order.descending);
    return qBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
}
