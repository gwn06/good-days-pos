import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class ProductInfo {
  int id;
  final int quantitySold;
  final int availableQuantity;
  final double costPrice;
  final double sellingPrice;
  final String category;
  final String? description;
  final String name;
  final DateTime expiryDate;
  final List<String> batchList;

  ProductInfo(
      {this.id = 0,
      required this.quantitySold,
      required this.availableQuantity,
      required this.costPrice,
      required this.sellingPrice,
      required this.category,
      required this.name,
      required this.expiryDate,
      required this.batchList,
      this.description});

  ProductInfo copyWith({
    int? id,
    int? quantitySold,
    int? availableQuantity,
    double? costPrice,
    double? sellingPrice,
    String? category,
    String? description,
    String? name,
    DateTime? expiryDate,
    List<String>? batchList,
  }) {
    return ProductInfo(
      id: id ?? this.id,
      quantitySold: quantitySold ?? this.quantitySold,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      category: category ?? this.category,
      description: description ?? this.description,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      batchList: batchList ?? this.batchList,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'quantitySold': quantitySold});
    result.addAll({'availableQuantity': availableQuantity});
    result.addAll({'costPrice': costPrice});
    result.addAll({'sellingPrice': sellingPrice});
    result.addAll({'category': category});
    if (description != null) {
      result.addAll({'description': description});
    }
    result.addAll({'name': name});
    result.addAll({'expiryDate': expiryDate.millisecondsSinceEpoch});
    result.addAll({'batchList': batchList});

    return result;
  }

  factory ProductInfo.fromMap(Map<String, dynamic> map) {
    return ProductInfo(
      id: map['id']?.toInt() ?? 0,
      quantitySold: map['quantitySold']?.toInt() ?? 0,
      availableQuantity: map['availableQuantity']?.toInt() ?? 0,
      costPrice: map['costPrice']?.toDouble() ?? 0.0,
      sellingPrice: map['sellingPrice']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'],
      name: map['name'] ?? '',
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      batchList: List<String>.from(map['batchList']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductInfo.fromJson(String source) =>
      ProductInfo.fromMap(json.decode(source));
}

class ProductBatch {
  final int amount;
  final DateTime date;
  final int id;

  ProductBatch({
    required this.amount,
    required this.date,
    required this.id,
  });

  ProductBatch copyWith({
    int? amount,
    DateTime? date,
    int? id,
  }) {
    return ProductBatch(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'amount': amount});
    result.addAll({'date': date.millisecondsSinceEpoch});
    result.addAll({'id': id});

    return result;
  }

  factory ProductBatch.fromMap(Map<String, dynamic> map) {
    return ProductBatch(
      amount: map['amount']?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      id: map['id']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductBatch.fromJson(String source) =>
      ProductBatch.fromMap(json.decode(source));
}
