import 'package:skribbl_client/models/game/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/input_container.dart';

class NameInput extends StatefulWidget {
  const NameInput({super.key});

  @override
  State<NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  late FocusNode focusNode;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(text: MePlayer.inst.name);
    textController.addListener(() => MePlayer.inst.name = textController.text);

    focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        // format spaces
        textController.text = textController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim();
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InputContainer(
            focusNode: focusNode,
            alignment: Alignment.centerLeft,
            height: 34,
            child: TextField(
              focusNode: focusNode,
              cursorColor: PanelStyles.color,
              controller: textController,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              style: const TextStyle(fontVariations: [FontVariation.weight(800)]),
              decoration: InputDecoration(
                  isDense: true,
                  constraints: const BoxConstraints.tightForFinite(),
                  border: InputBorder.none,
                  hintText: 'name_input_placeholder'.tr,
                  hintStyle: const TextStyle(fontVariations: [FontVariation.weight(800)], color: Colors.black38)),
            )));
  }
}
