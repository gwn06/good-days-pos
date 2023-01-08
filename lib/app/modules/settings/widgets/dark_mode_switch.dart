import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/theme/theme_provider.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkModeSwitch extends ConsumerStatefulWidget {
  const DarkModeSwitch({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DarkModeSwitchState();
}

class _DarkModeSwitchState extends ConsumerState<DarkModeSwitch> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    bool checked = appThemeState.isDarkModeEnabled;
    return ToggleSwitch(
      checked: checked,
      content: Text(checked ? 'Dark' : 'Light'),
      onChanged: (enabled) {
        setState(() {
          checked = enabled;
          _prefs.then((prefs) => prefs.setBool(isDarkModeSelected, enabled));
          if (enabled) {
            appThemeState.setDarkTheme();
          } else {
            appThemeState.setLightTheme();
          }
        });
      },
    );
  }
}
