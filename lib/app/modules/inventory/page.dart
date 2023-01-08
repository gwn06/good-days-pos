import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/modules/inventory/widgets/all_products.dart';
import 'package:pos_system/app/modules/inventory/widgets/expired.dart';
import 'package:pos_system/app/modules/inventory/widgets/new_product.dart';
import 'package:pos_system/app/modules/inventory/widgets/out_of_stock.dart';
import 'package:pos_system/app/modules/inventory/widgets/soon_expire.dart';
import 'package:pos_system/app/modules/inventory/widgets/soon_out_of_stock.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _index = 0;
  final _screens = [
    const AllProducts(),
    const SoonOutOfStock(),
    const OutOfStock(),
    const SoonExpire(),
    const Expired(),
    const NewProduct()
  ];
  @override
  Widget build(BuildContext context) {
    return NavigationView(
        pane: NavigationPane(
          displayMode: PaneDisplayMode.top,
          selected: _index,
          onChanged: (i) => setState(() => _index = i),
          items: [
            PaneItem(
                icon: const Icon(FluentIcons.product),
                title: const Text(AppStrings.allProducts)),
            PaneItem(
                icon: const Icon(FluentIcons.info),
                title: const Text(AppStrings.soonOutOfStock)),
            PaneItem(
                icon: const Icon(FluentIcons.down),
                title: const Text(AppStrings.outOfStock)),
            PaneItem(
                icon: const Icon(FluentIcons.product_warning),
                title: const Text(AppStrings.soonExpire)),
            PaneItem(
                icon: const Icon(FluentIcons.error_badge),
                title: const Text(AppStrings.expired)),
            PaneItem(
                icon: const Icon(FluentIcons.add),
                title: const Text(AppStrings.newProduct)),
          ],
        ),
        content: NavigationBody.builder(
            index: _index, itemBuilder: (context, index) => _screens[index]));
  }
}
