import 'package:pos_system/app/core/values/strings.dart';

enum DiscountType {
  percentage,
  cashAmount,
}

extension DiscountTypeExtension on DiscountType {
  String get displayDiscount {
    switch (this) {
      case DiscountType.percentage:
        return AppStrings.percentage;
      case DiscountType.cashAmount:
        return AppStrings.amount;
    }
  }
}
