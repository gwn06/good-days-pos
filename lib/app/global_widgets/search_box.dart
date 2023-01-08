import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/core/values/values.dart';

class SearchBox extends StatefulWidget {
  final Function(String) callback;
  const SearchBox({Key? key, required this.callback}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final searchController = TextEditingController(text: '');
  @override
  void initState() {
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {});
      }
      if (searchController.text.length == 1 && mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p60),
      child: TextFormBox(
        onChanged: ((value) {
          widget.callback(value);
        }),
        autofocus: true,
        controller: searchController,
        placeholder: AppStrings.searchPlaceholder,
        suffixMode: OverlayVisibilityMode.always,
        suffix: searchController.text.isEmpty
            ? const Icon(FluentIcons.search)
            : IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: () {
                  widget.callback(AppStrings.emptyString);
                  searchController.clear();
                },
              ),
      ),
    );
  }
}
