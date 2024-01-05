import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NameInput extends StatelessWidget {
  const NameInput({super.key});

  @override
  Widget build(BuildContext context) {
    var homeController = Get.find<HomeController>();
    return Expanded(
        child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: InputStyles.decoration,
            height: 34,
            child: TextField(
              onChanged: (String text) => homeController.name = text,
              inputFormatters: [LengthLimitingTextInputFormatter(20), _NoLeadingSpaceFormatter(), _NoMultipleSpacesFormatter()],
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'name_input_placeholder'.tr,
                  hintStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black38)),
            )));
  }
}

class _NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    } else {
      return newValue;
    }
  }
}

class _NoMultipleSpacesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final modifiedText = newValue.text.replaceAll(RegExp(r'\s\s+'), ' ');
    return TextEditingValue(
      text: modifiedText,
      selection: TextSelection.collapsed(offset: modifiedText.length)
    );
  }
}
