import 'package:skribbl_client/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class LangSelector extends StatelessWidget {
  const LangSelector({super.key});

  @override
  Widget build(BuildContext context) {
    var translations = AppTranslation.translations;
    return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Dropdown(
          height: 34,
          width: 120,
          value: Get.locale.toString(),
          items: translations.entries
              .map((e) => DropdownItem(
                  value: e.key,
                  child: Text(e.value['displayName'] ?? '',
                      style: const TextStyle(
                          fontFamily: 'Nunito-var', fontVariations: [FontVariation.weight(500)], fontSize: 16))))
              .toList(),
          onChange: (value) {
            var list = value.split('_');
            Get.updateLocale(Locale(list[0], list[1]));
          },
        ));
    // var translations = AppTranslation.translations;
    // var items = translations.entries
    //     .map((entry) => DropdownMenuItem(
    //         value: entry.key,
    //         child: Text(
    //           entry.value['displayName'] ?? '',
    //           style:
    //               const TextStyle(fontFamily: 'Nunito-var', fontVariations: [FontVariation.weight(500)], fontSize: 16),
    //         )))
    //     .toList();
    // return InputContainer(
    //     padding: const EdgeInsets.only(left: 10),
    //     height: 34,
    //     width: 120,
    //     focusNode: focusNode,
    //     margin: const EdgeInsets.only(left: 4),
    //     child: DropdownButtonHideUnderline(
    //         child: DropdownButton(
    //             focusNode: focusNode,
    //             icon: const Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
    //             // padding: const EdgeInsets.only(left: 7),
    //             isDense: true,
    //             isExpanded: true,
    //             value: Get.locale.toString(),
    //             items: items,
    //             onChanged: (String? strLocale) {
    //               var list = strLocale!.split('_');
    //               Get.updateLocale(Locale(list[0], list[1]));
    //             })));
  }
}
