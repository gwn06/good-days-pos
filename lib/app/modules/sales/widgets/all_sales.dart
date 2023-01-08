import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';

import 'base_sales_history.dart';

class AllSales extends StatelessWidget {
  const AllSales({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseSalesHistory(
        filterBy: FilterSalesBy.allSales, header: "All Sales");
  }
}
