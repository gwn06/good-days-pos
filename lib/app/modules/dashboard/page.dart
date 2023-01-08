import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/modules/dashboard/widgets/overview.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // int _index = 0;
  // final _screens = [Overview(), Reports(), StockValue()];
  @override
  Widget build(BuildContext context) {
    return const NavigationView(
      content: Overview(),
    );
    // content: NavigationBody.builder(
    //     index: _index, itemBuilder: (context, index) => _screens[index]));
  }
}
