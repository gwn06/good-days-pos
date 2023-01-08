import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/colors.dart';
import 'package:pos_system/app/core/values/functions.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/core/values/values.dart';
import 'package:pos_system/app/data/data_source/sales_history_data_source.dart';
import 'package:pos_system/app/data/repository/repository.dart';
import 'package:pos_system/app/modules/dashboard/widgets/horizontal_line_title.dart';
import 'package:pos_system/app/modules/settings/widgets/dark_mode_switch.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final Repository _repository;
  late final SalesHistoryDataSource _salesHistoryDataSource;

  @override
  void initState() {
    _repository = ref.read(repositoryProvider);
    _salesHistoryDataSource = ref.read(salesHistoryProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text(AppStrings.settings)),
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HorizontalLineTitle(title: 'THEMES'),
            const DarkModeSwitch(),
            const HorizontalLineTitle(title: 'DANGER ZONE'),
            const SizedBox(height: AppSize.s12),
            FilledButton(
                style: ButtonStyle(backgroundColor: ButtonState.resolveWith(
                  (states) {
                    if (states.isHovering) {
                      return ColorManager.red4;
                    }
                    return Colors.red;
                  },
                )),
                child: const Text('DELETE All SALES'),
                onPressed: () {
                  _deleteAllDialog(
                      title: 'DELETE ALL',
                      dbType: 'SALES',
                      onPressed: () {
                        _salesHistoryDataSource.removeAllSaleHistory();
                        showTopSnackbar(
                            context: context,
                            message: 'ALL SALES has been deleted',
                            severity: InfoBarSeverity.info,
                            title: AppStrings.success);
                        Navigator.pop(context);
                      });
                }),
            const SizedBox(height: AppSize.s12),
            FilledButton(
                style: ButtonStyle(backgroundColor: ButtonState.resolveWith(
                  (states) {
                    if (states.isHovering) {
                      return ColorManager.red4;
                    }
                    return Colors.red;
                  },
                )),
                child: const Text('DELETE All PRODUCTS'),
                onPressed: () {
                  _deleteAllDialog(
                      title: 'DELETE ALL',
                      dbType: 'PRODUCTS',
                      onPressed: () {
                        _repository.deleteAllProducts();
                        showTopSnackbar(
                            context: context,
                            message: 'ALL PRODUCTS has been deleted',
                            severity: InfoBarSeverity.info,
                            title: AppStrings.success);
                        Navigator.pop(context);
                      });
                  // _repository.deleteAllProducts();
                }),
          ],
        ),
      ),
    );
  }

  void _deleteAllDialog(
      {required String title,
      required String dbType,
      required void Function() onPressed}) {
    final deleteMsg = 'delete all $dbType';
    bool enabled = false;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return ContentDialog(
              title: Text('$title $dbType'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(
                    placeholder: 'Type: $deleteMsg',
                    onChanged: (value) {
                      if (value == deleteMsg) {
                        setDialogState(() {
                          enabled = true;
                        });
                      }
                    },
                  )
                ],
              ),
              actions: [
                FilledButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Button(
                    onPressed: enabled ? onPressed : null,
                    child: const Text('DELETE'))
              ],
            );
          });
        });
  }
}
