import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/data/data_source/local_data_source.dart';

import 'base_inventory.dart';

class SoonExpire extends StatelessWidget {
  const SoonExpire({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseInventory(
      filterBy: FilterBy.soonToExpire,
      header: AppStrings.soonExpire,
    );
  }
}
