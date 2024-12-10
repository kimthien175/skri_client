import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class GameCheckbox extends StatefulWidget {
  const GameCheckbox({super.key, this.value = false, this.onChanged});

  final bool value;
  final void Function(bool value)? onChanged;

  @override
  State<GameCheckbox> createState() => _GameCheckboxState();
}

class _GameCheckboxState extends State<GameCheckbox> with SingleTickerProviderStateMixin {
  late final FocusNode focusNode;
  late final AnimationController controller;
  late final Animation<double> animation;
  late bool value = widget.value;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            toggle();
          }
        }
        return KeyEventResult.ignored;
      },
    );
    controller = AnimationController(
        vsync: this, duration: AnimatedButton.duration); //, value: value ? 1 : 0);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
  }

  toggle() {
    value = !value;
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
    controller.toggle();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void onTap() {
    if (!focusNode.hasFocus) focusNode.requestFocus();
    toggle();
  }

  final double childSize = 20 * sqrt(2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Focus(
            focusNode: focusNode,
            child: InputContainer(
                padding: null,
                constraints: const BoxConstraints.expand(width: 20, height: 20),
                focusNode: focusNode,
                child: ScaleTransition(
                    scale: animation,
                    child: ClipRRect(
                        borderRadius: GlobalStyles.borderRadius,
                        child: OverflowBox(
                            maxHeight: childSize,
                            maxWidth: childSize,
                            child: Container(
                              constraints: const BoxConstraints.expand(),
                              decoration: const BoxDecoration(
                                  color: GlobalStyles.colorPanelButton, shape: BoxShape.circle),
                            )))))));
  }
}
