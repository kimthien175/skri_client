import 'package:skribbl_client/generated/locales.g.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/input_container.dart';

class LangSelector extends StatefulWidget {
  const LangSelector({super.key});

  @override
  State<LangSelector> createState() => _LangSelectorState();
}

class _LangSelectorState extends State<LangSelector> {
  late FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var translations = AppTranslation.translations;
    var items = translations.entries
        .map((entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              entry.value['displayName'] ?? '',
              style:
                  const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 16),
            )))
        .toList();
    return InputContainer(
        padding: const EdgeInsets.only(left: 10),
        height: 34,
        width: 120,
        focusNode: focusNode,
        margin: const EdgeInsets.only(left: 4),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
                focusNode: focusNode,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
                // padding: const EdgeInsets.only(left: 7),
                isDense: true,
                isExpanded: true,
                value: Get.locale.toString(),
                items: items,
                onChanged: (String? strLocale) {
                  var list = strLocale!.split('_');
                  Get.updateLocale(Locale(list[0], list[1]));
                })));
  }
}
