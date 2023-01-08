import 'dart:convert';

// import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pos_system/app/data/model/product.dart';

// part 'product_item.freezed.dart';

// @freezed
// class ShoppingCart with _$ShoppingCart {
//   factory ShoppingCart({
//     required ProductInfo product,
//     required int amount,
//   }) = _ShoppingCart;
// }

class ShoppingCart {
  final int amount;
  final ProductInfo product;

  ShoppingCart({required this.amount, required this.product});

  ShoppingCart copyWith({
    int? amount,
    ProductInfo? product,
  }) {
    return ShoppingCart(
      amount: amount ?? this.amount,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'amount': amount});
    result.addAll({'product': product.toMap()});

    return result;
  }

  factory ShoppingCart.fromMap(Map<String, dynamic> map) {
    return ShoppingCart(
      amount: map['amount']?.toInt() ?? 0,
      product: ProductInfo.fromMap(map['product']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingCart.fromJson(String source) =>
      ShoppingCart.fromMap(json.decode(source));
}
