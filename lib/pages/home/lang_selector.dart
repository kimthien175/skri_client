import 'package:cd_mobile/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LangSelector extends StatelessWidget {
  const LangSelector({super.key});

  @override
  Widget build(BuildContext context) {
    var translations = AppTranslation.translations;
    var items = translations.entries
        .map((entry) =>
            DropdownMenuItem(value: entry.key, child: Text(entry.value['displayName'] ?? '')))
        .toList();
    return DropdownButton(
      value: Get.locale.toString(),
        items: items,
        onChanged: (String? strLocale) {
          var list = strLocale!.split('_');
          Get.updateLocale(Locale(list[0], list[1]));
        });
  }
}
