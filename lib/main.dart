import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/theme/my_theme.dart';
import 'package:pos_system/app/core/theme/theme_provider.dart';
import 'package:pos_system/app/core/utils/sp_helper.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/data/data_source/objectbox_database.dart';
import 'package:pos_system/app/modules/home/page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

late final ObjectBoxDatabase objectBox;

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBoxDatabase.create();
  await SPHelper.sp.initSharedPreferences();

  if (isDesktop) {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      // await windowManager.setTitleBarStyle(
      //   TitleBarStyle.hidden,
      //   windowButtonVisibility: false,
      // );
      // await windowManager.setSize(const Size(755, 545));
      await windowManager.setTitle(AppStrings.appName);
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    return FluentApp(
      scrollBehavior: MyCustomScrollBehavior(),
      title: AppStrings.appName,
      theme: MyTheme.getLight(),
      darkTheme: MyTheme.getDark(),
      themeMode:
          appThemeState.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyCustomScrollBehavior extends FluentScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
