import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NameInput extends StatelessWidget {
  const NameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: InputStyles.decoration,
            height: 34,
            child: _TextField()));
  }
}

class _TextField extends StatelessWidget {
  _TextField() {
    if (MePlayer.isCreated) {
      textController.text = MePlayer.inst.name;
    }
  }
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: const Key(''),
        onVisibilityChanged: (visibilityInfo) {
          textController.text = MePlayer.inst.name;
        },
        child: TextField(
          controller: textController,
          onChanged: (String text) => MePlayer.inst.name = text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            _NoLeadingSpaceFormatter(),
            _NoMultipleSpacesFormatter()
          ],
          style: const TextStyle(fontWeight: FontWeight.w800),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'name_input_placeholder'.tr,
              hintStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black38)),
        ));
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
