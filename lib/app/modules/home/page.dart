import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/modules/account/page.dart';
import 'package:pos_system/app/modules/dashboard/page.dart';
import 'package:pos_system/app/modules/inventory/page.dart';
import 'package:pos_system/app/modules/sales/page.dart';
import 'package:pos_system/app/modules/settings/page.dart';
import 'package:pos_system/app/modules/shop/page.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  int _currentPage = 0;
  static final _items = [
    PaneItem(
      icon: const Icon(FluentIcons.shopping_cart),
      title: const Text(AppStrings.shop),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.view_dashboard),
      title: const Text(AppStrings.dashboard),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.database),
      title: const Text(AppStrings.inventory),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.financial),
      title: const Text(AppStrings.sales),
    ),
  ];
  static final _footerItems = [
    PaneItem(
        icon: const Icon(FluentIcons.account_management),
        title: const Text(AppStrings.employees)),
    PaneItem(
        icon: const Icon(FluentIcons.settings),
        title: const Text(AppStrings.settings))
  ];

  static const List<Widget> _pages = [
    ShopPage(),
    DashboardPage(),
    InventoryPage(),
    SalesPage(),
    AccountPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    super.onWindowClose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: _currentPage,
        onChanged: (i) => setState(() => _currentPage = i),
        displayMode: PaneDisplayMode.compact,
        items: _items,
        footerItems: _footerItems,
      ),
      content: NavigationBody.builder(
        index: _currentPage,
        transitionBuilder: (child, animation) =>
            EntrancePageTransition(animation: animation, child: child),
        itemBuilder: (context, index) => _pages[index],
      ),
    );
  }
}
