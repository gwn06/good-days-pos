import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/font.dart';

class HorizontalLineTitle extends StatelessWidget {
  final String title;
  const HorizontalLineTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      Text(
        title,
        style: const TextStyle(
            fontSize: FontSize.s20, fontWeight: FontWeight.bold),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
