import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/data/data_source/local_data_source.dart';

import 'base_inventory.dart';

class Expired extends StatelessWidget {
  const Expired({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseInventory(
      filterBy: FilterBy.expired,
      header: AppStrings.expired,
    );
  }
}
