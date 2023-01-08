import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/data/data_source/local_data_source.dart';
import 'package:pos_system/app/modules/inventory/widgets/base_inventory.dart';

class OutOfStock extends StatelessWidget {
  const OutOfStock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseInventory(
      filterBy: FilterBy.outOfStock,
      header: AppStrings.outOfStock,
    );
  }
}
