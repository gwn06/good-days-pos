import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_system/app/data/model/income.dart';
import 'package:pos_system/app/data/model/product_item.dart';
import 'package:pos_system/app/data/model/sales_history.dart';

Future<String> getFilePath() async {
  const folderName = 'Inventory_Reports';
  final appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = '${appDocumentsDirectory.path}/$folderName'; // 2
  await Directory(appDocumentsPath).create();
  String filePath = appDocumentsPath; // 3

  return filePath;
}

void showTopSnackbar(
    {required BuildContext context,
    required String message,
    required InfoBarSeverity severity,
    required String title}) {
  showSnackbar(
      context,
      SizedBox(
        height: 40,
        width: 350,
        child: InfoBar(
          title: Text(title),
          severity: severity,
          content: Text(message),
        ),
      ),
      alignment: Alignment.topCenter);
}

Income calculateIncome({required List<SalesHistory> sales}) {
  double profit = 0;
  double revenue = 0;
  double discounts = 0;
  double totalCosts = 0;
  for (final sale in sales) {
    discounts += sale.discount;
    final cart = json.decode(sale.shoppingCart) as Map<String, dynamic>;
    for (var data in cart.entries) {
      final product = ShoppingCart.fromJson(data.value);
      revenue += (product.amount * product.product.sellingPrice);
      totalCosts += (product.amount * product.product.costPrice);
    }
  }
  profit = revenue - totalCosts - discounts;
  return Income(profit: profit, revenue: revenue, discounts: discounts);
}
