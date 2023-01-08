import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/data/managers/product_batch_manager.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/product_item.dart';

final shoppingCartManagerProvider = Provider<ShoppingCartManager>((ref) {
  return ShoppingCartManagerImpl();
});

abstract class ShoppingCartManager {
  Map<String, ShoppingCart> get shoppingCart;
  double get grandTotal;
  double get subTotal;
  double get discount;
  set discount(double newDiscount);
  void calculateBill();
  void addToCart(int id, ProductInfo item);
  void setProductAmount(int amount, String key, {required ProductInfo product});
  void updateSellingPrice(String key, double selectedPrice);
  ProductInfo updateProductBatchAmount(
      {required ProductInfo cartProduct,
      required ProductInfo originalProduct,
      required int amount});
  void removeProduct(String key);
  void increaseProductAmount(String key, {required ProductInfo product});
  void decreaseProductAmount(String key, {required ProductInfo product});
  bool canAddToCart(String key, int availableStock);
}

class ShoppingCartManagerImpl implements ShoppingCartManager {
  double _discount = 0;
  double _grandTotal = 0;
  double _subTotal = 0;
  final Map<String, ShoppingCart> _shoppingCart = {};
  final ProductBatchManager _batchManager = ProductBatchManagerImpl();

  @override
  void addToCart(int id, ProductInfo product) {
    _shoppingCart.update(id.toString(), (cartProduct) {
      final updatedProduct = updateProductBatchAmount(
          cartProduct: cartProduct.product,
          originalProduct: product,
          amount: kOne);
      return cartProduct.copyWith(
          amount: cartProduct.amount + kOne, product: updatedProduct);
    }, ifAbsent: () {
      var batch = product.batchList.first;
      var singleBatchAmount =
          ProductBatch.fromJson(batch).copyWith(amount: kOne);
      var updatedProduct =
          product.copyWith(batchList: [singleBatchAmount.toJson()]);

      return ShoppingCart(product: updatedProduct, amount: kOne);
    });
  }

  @override
  void calculateBill() {
    _subTotal = 0;
    _grandTotal = 0;
    for (var element in _shoppingCart.entries) {
      _subTotal += element.value.product.sellingPrice * element.value.amount;
      _grandTotal = _subTotal - _discount;
    }
  }

  @override
  void removeProduct(String key) {
    _shoppingCart.remove(key);
  }

  @override
  void setProductAmount(int amount, String key,
      {required ProductInfo product}) {
    final availableStock = _shoppingCart[key]?.product.availableQuantity;
    if (availableStock != null && availableStock <= amount) {
      _shoppingCart.update(key, (cartProduct) {
        final updatedProduct = updateProductBatchAmount(
            cartProduct: cartProduct.product,
            originalProduct: product,
            amount: availableStock);
        return cartProduct.copyWith(
            amount: availableStock, product: updatedProduct);
      });
      return;
    }
    if (amount <= zero) {
      _shoppingCart.remove(key);
      return;
    }
    _shoppingCart.update(key, (cartProduct) {
      final updatedProduct = updateProductBatchAmount(
          cartProduct: cartProduct.product,
          originalProduct: product,
          amount: amount);
      return cartProduct.copyWith(amount: amount, product: updatedProduct);
    });
  }

  @override
  get discount => _discount;

  @override
  set discount(double newDiscount) {
    _discount = newDiscount;
  }

  @override
  get grandTotal => _grandTotal;

  @override
  get shoppingCart => _shoppingCart;

  @override
  get subTotal => _subTotal;

  @override
  void updateSellingPrice(String key, double selectedPrice) {
    _shoppingCart.update(
        key,
        (value) => value.copyWith(
            product: value.product.copyWith(sellingPrice: selectedPrice)));
  }

  @override
  void decreaseProductAmount(String key, {required ProductInfo product}) {
    setProductAmount(_shoppingCart[key]!.amount - kOne, key, product: product);
  }

  @override
  void increaseProductAmount(String key, {required ProductInfo product}) {
    setProductAmount(_shoppingCart[key]!.amount + kOne, key, product: product);
  }

  @override
  bool canAddToCart(String key, int availableStock) {
    final product = _shoppingCart[key];
    if (product == null || (product.amount < availableStock)) {
      return true;
    }
    return false;
  }

  @override
  ProductInfo updateProductBatchAmount(
      {required ProductInfo cartProduct,
      required ProductInfo originalProduct,
      required int amount}) {
    var cartBatchList = cartProduct.batchList
        .map((batch) => ProductBatch.fromJson(batch))
        .toList();
    var originalProductBatchList = originalProduct.batchList
        .map((batch) => ProductBatch.fromJson(batch))
        .toList();
    var updatedCartBatchList = _batchManager.updateCartBatchAmount(
        cartBatchList: cartBatchList,
        productBatchList: originalProductBatchList,
        amount: amount);
    var updatedProduct = cartProduct.copyWith(
        batchList:
            updatedCartBatchList.map((batch) => batch.toJson()).toList());
    return updatedProduct;
  }
}
