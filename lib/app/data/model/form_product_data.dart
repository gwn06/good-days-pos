import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_product_data.freezed.dart';

@freezed
class FormProductData with _$FormProductData {
  factory FormProductData(
      {@Default('') String productName,
      @Default('') String category,
      @Default(0) double costPrice,
      @Default(0) double sellingPrice,
      @Default(0) int availableStock,
      @Default(0) int quantitySold,
      required DateTime expiryDate,
      @Default('') String description}) = _FormProductData;
}

class FormProductBatch {
  final int amount;
  final DateTime date;

  FormProductBatch({required this.amount, required this.date});

  FormProductBatch.empty()
      : amount = 0,
        date = DateTime.now();

  FormProductBatch copyWith({
    int? amount,
    DateTime? date,
  }) {
    return FormProductBatch(
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
