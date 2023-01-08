import 'package:objectbox/objectbox.dart';

@Entity()
class SalesHistory {
  int id;
  final int employeeId;
  final DateTime date;
  final String shoppingCart;
  final double discount;
  final double subtotal;
  final double grandTotal;

  SalesHistory(
      {this.id = 0,
      required this.discount,
      required this.subtotal,
      required this.grandTotal,
      required this.employeeId,
      required this.date,
      required this.shoppingCart});

  SalesHistory copyWith({
    int? id,
    int? employeeId,
    DateTime? date,
    String? shoppingCart,
    double? discount,
    double? subtotal,
    double? grandTotal,
  }) {
    return SalesHistory(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      shoppingCart: shoppingCart ?? this.shoppingCart,
      discount: discount ?? this.discount,
      subtotal: subtotal ?? this.subtotal,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }
}
