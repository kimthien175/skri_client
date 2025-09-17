import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/widgets/overlay/newgame_tooltip.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import 'settings.dart';

class KeyBinding extends StatefulWidget {
  const KeyBinding({super.key, required this.title, required this.actKey});
  final String title;
  final LogicalKeyboardKey actKey;

  @override
  State<KeyBinding> createState() => _KeyBindingState();
}

class _KeyBindingState extends State<KeyBinding> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late NewGameTooltipController tooltip = NewGameTooltipController(
      controller: controller,
      tooltip: Builder(
          builder: (_) => Text('key_binding_warning'.trParams({'duplicated': duplicatedKey.tr}))),
      position: const NewGameTooltipPosition.centerBottom(
          backgroundColor: GameTooltipBackgroundColor.warining));

  String duplicatedKey = "none";

  late FocusNode focusNode;

  bool isModifying = false;

  late final Widget questionMark =
      FittedBox(child: GifManager.inst.misc('questionmark').builder.init());

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: AnimatedButton.duration);
    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          var key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter) {
            modify();
            return KeyEventResult.handled;
          }

          if (isModifying) {
            if (key == LogicalKeyboardKey.space || key.keyLabel.length == 1) {
              if (!SystemSettings.inst.changeKey(widget.actKey, key)) {
                duplicatedKey = SystemSettings.inst.keyMaps[key]!.title;
                tooltip.show();
                return KeyEventResult.handled;
              }

              submit();
              return KeyEventResult.handled;
            }
          }

          if (key == LogicalKeyboardKey.escape) {
            if (!isModifying) return KeyEventResult.ignored;
            submit();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        submit();
      }
    });
  }

  void modify() {
    setState(() {
      isModifying = true;
    });
  }

  void submit() {
    if (tooltip.isShowing) tooltip.hide();
    setState(() {
      isModifying = false;
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  String keyLabel(LogicalKeyboardKey key) =>
      key.keyLabel.trim().isNotEmpty ? key.keyLabel : key.debugName.toString();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12),
      Text(widget.title.tr,
          style: const TextStyle(fontSize: 15, fontVariations: [FontVariation.weight(440)])),
      const SizedBox(height: 5),
      GestureDetector(
          onTap: () {
            focusNode.requestFocus();
            modify();
          },
          child: InputContainer(
              width: 80,
              height: 30,
              alignment: Alignment.center,
              focusNode: focusNode,
              child: Focus(
                  focusNode: focusNode,
                  child: isModifying
                      ? questionMark
                      : Text(
                          keyLabel(widget.actKey),
                          style: const TextStyle(
                              color: Colors.black, fontVariations: [FontVariation.weight(750)]),
                        )))),
      const SizedBox(height: 12)
    ]);
  }
}
