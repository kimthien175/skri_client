import 'package:skribbl_client/generated/locales.g.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LangSelector extends StatelessWidget {
  const LangSelector({super.key});

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
    return Container(
        height: 34,
        width: 120,
        decoration: InputStyles.decoration,
        margin: const EdgeInsets.only(left: 4),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
                padding: const EdgeInsets.only(left: 7),
                isExpanded: true,
                value: Get.locale.toString(),
                items: items,
                onChanged: (String? strLocale) {
                  var list = strLocale!.split('_');
                  Get.updateLocale(Locale(list[0], list[1]));
                })));
  }
}
