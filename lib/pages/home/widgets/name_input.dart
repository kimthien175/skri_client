import 'package:skribbl_client/models/game/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/input_container.dart';
//import 'package:visibility_detector/visibility_detector.dart';

class NameInput extends StatelessWidget {
  const NameInput({super.key});

  @override
  Widget build(BuildContext context) {
    var focusNode = FocusNode();
    return Expanded(
        child: InputContainer(
            focusNode: focusNode,
            alignment: Alignment.centerLeft,
            height: 34,
            child: TextField(
              focusNode: focusNode,
              cursorColor: PanelStyles.color,
              controller: TextEditingController(text: MePlayer.inst.name),
              onChanged: (String text) => MePlayer.inst.name = text,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                _NoLeadingSpaceFormatter(),
                _NoMultipleSpacesFormatter()
              ],
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                  isDense: true,
                  constraints: const BoxConstraints.tightForFinite(),
                  border: InputBorder.none,
                  hintText: 'name_input_placeholder'.tr,
                  hintStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black38)),
            )));
  }
}

class _NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.text.startsWith(' ') ? oldValue : newValue;
}

class _NoMultipleSpacesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final modifiedText = newValue.text.replaceAll(RegExp(r'\s\s+'), ' ');
    return TextEditingValue(
        text: modifiedText, selection: TextSelection.collapsed(offset: modifiedText.length));
  }
}
