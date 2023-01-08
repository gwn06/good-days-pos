import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';
import 'package:pos_system/app/modules/sales/widgets/base_sales_history.dart';

class SalesByDate extends StatelessWidget {
  const SalesByDate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseSalesHistory(
        filterBy: FilterSalesBy.selectedDate, header: AppStrings.salesByDate);
  }
}
