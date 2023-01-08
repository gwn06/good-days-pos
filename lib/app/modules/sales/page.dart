import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/modules/sales/widgets/all_sales.dart';
import 'package:pos_system/app/modules/sales/widgets/sales_by_date.dart';
import 'package:pos_system/app/modules/sales/widgets/todays_sale.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  int _index = 0;
  final _screens = const [AllSales(), TodaysSale(), SalesByDate()];
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        selected: _index,
        onChanged: (i) => setState(() => _index = i),
        items: [
          PaneItem(
              icon: const Icon(FluentIcons.coupon),
              title: const Text(AppStrings.allSales)),
          PaneItem(
              icon: const Icon(FluentIcons.goto_today),
              title: const Text(AppStrings.salesToday)),
          PaneItem(
              icon: const Icon(FluentIcons.date_time),
              title: const Text(AppStrings.salesByDate)),
        ],
      ),
      content: NavigationBody.builder(
          index: _index, itemBuilder: (context, index) => _screens[index]),
    );
  }
}
