import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/utils/sp_helper.dart';
import 'package:pos_system/app/core/values/constants.dart';

class MyTheme {
  static ThemeData getLight() {
    return ThemeData(
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData getDark() {
    return ThemeData(
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class AppThemeState extends ChangeNotifier {
  var isDarkModeEnabled =
      SPHelper.sp.prefs?.getBool(isDarkModeSelected) ?? false;

  void setLightTheme() {
    isDarkModeEnabled = false;
    notifyListeners();
  }

  void setDarkTheme() {
    isDarkModeEnabled = true;
    notifyListeners();
  }
}
