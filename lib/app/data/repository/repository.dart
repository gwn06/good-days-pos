import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/internal.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/data/data_source/local_data_source.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

final repositoryProvider = Provider<Repository>((ref) {
  final localDb = ref.watch(localDataSourceProvider);
  final salesHistoryDb = ref.watch(salesHistoryProvider);
  return RepositoryImpl(localDb, salesHistoryDb);
});

abstract class Repository {
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
  void addProduct(ProductInfo item);
  void addProducts({required List<ProductInfo> products});
  void deleteProduct(int id);
  void deleteAllProducts();
  void updateProduct({int? id, required ProductInfo product});
  Future<void> updateProductsAndAddToSales(
      {required Map<String, ShoppingCart> cart,
      required double discount,
      required double subtotal,
      required double grandTotal});
  Stream<List<ProductInfo>> sortProducts(
      QueryProperty<ProductInfo, dynamic> sortField, bool ascending);
}

class RepositoryImpl implements Repository {
  final LocalDataSource _localDb;
  final SalesHistoryDataSource _salesHistoryDb;
  late final Future<SharedPreferences> _prefs;

  RepositoryImpl(this._localDb, this._salesHistoryDb)
      : _prefs = SharedPreferences.getInstance();

  @override
  void addProduct(ProductInfo item) {
    _localDb.addProduct(item);
  }

  @override
  void addProducts({required List<ProductInfo> products}) {
    _localDb.addProducts(products: products);
  }

  @override
  void deleteProduct(int id) {
    _localDb.deleteProduct(id);
  }

  @override
  Stream<List<ProductInfo>> getAllProducts() {
    return _localDb.getAllProducts();
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
    return _localDb.getFilteredProducts(query,
        filterBy: filterBy,
        sortField: sortField,
        ascending: ascending,
        maxRange: maxRange,
        minRange: minRange);
  }

  @override
  void updateProduct({int? id, required ProductInfo product}) {
    _localDb.updateProduct(id: id, product: product);
  }

  @override
  ProductInfo? findProduct({int? id, String? name}) {
    return _localDb.findProduct(id: id, name: name);
  }

  @override
  bool isProductExist({int? id, String? name}) {
    return _localDb.isProductExist(id: id, name: name);
  }

  @override
  Future<void> updateProductsAndAddToSales(
      {required Map<String, ShoppingCart> cart,
      required double discount,
      required double subtotal,
      required double grandTotal}) async {
    // for (var cart in cart.values) {
    //   print(cart.product.batchList);
    // }
    final employeeId =
        await _prefs.then((value) => value.getInt(selectedEmployeeIdPref));
    final today = DateTime.now();
    final sale = SalesHistory(
        discount: discount,
        subtotal: subtotal,
        grandTotal: grandTotal,
        employeeId: employeeId ?? -1,
        date: today,
        shoppingCart: json.encode(cart));
    _salesHistoryDb.addToSalesHistory(sale);
    _localDb.updateProducts(cart: cart);
  }

  @override
  Stream<List<ProductInfo>> sortProducts(
      QueryProperty<ProductInfo, dynamic> sortField, bool ascending) {
    return _localDb.sortProducts(sortField, ascending);
  }

  @override
  void deleteAllProducts() {
    _localDb.deleteAllProducts();
  }
}
