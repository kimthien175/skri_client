library avatar_editor;

export 'controller.dart';
export 'jiggle_avatar.dart';

import 'package:flutter/services.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class AvatarEditor extends GetView<AvatarEditorController> {
  const AvatarEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1), borderRadius: GlobalStyles.borderRadius),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _SwitchButton('left_arrow', 'chosen_left_arrow', controller.onPreviousEyes),
                  _SwitchButton('left_arrow', 'chosen_left_arrow', controller.onPreviousMouth),
                  _SwitchButton('left_arrow', 'chosen_left_arrow', controller.onPreviousColor),
                ],
              ),
              const SizedBox(height: 96, width: 96, child: FittedBox(child: JiggleAvatar())),
              Column(
                children: [
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextEyes),
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextMouth),
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextColor),
                ],
              ),
            ],
          )),
      const Positioned(right: 4, top: 14, child: _RandomButton())
    ]);
  }
}

class _SwitchButton extends StatefulWidget {
  const _SwitchButton(this.path, this.onHoverPath, this.callback);

  final String path;
  final String onHoverPath;
  final Function() callback;

  @override
  State<_SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<_SwitchButton> with SingleTickerProviderStateMixin {
  late final GifBuilder child = GifManager.inst.misc(widget.path).builder.init();
  late final GifBuilder onHoverChild = GifManager.inst.misc(widget.onHoverPath).builder.init();

  late final AnimationController animController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> animation =
      CurvedAnimation(parent: animController, curve: Curves.linear);

  late Widget visual;

  late final FocusNode focusNode;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    visual = child;

    focusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          widget.callback();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });

    focusNode.addListener(() {
      if (isHovered) return;
      if (focusNode.hasFocus) {
        change(onHoverChild);
      } else {
        change(child);
      }
    });

    if (focusNode.hasFocus) change(onHoverChild);
  }

  @override
  void dispose() {
    animController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  change(Widget newWidget) {
    setState(() {
      visual = Stack(
        children: [
          newWidget,
          FadeTransition(opacity: animation, child: visual),
        ],
      );
    });
    animController.reverse(from: 1).then((_) {
      visual = newWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: focusNode,
        child: SizedBox(
            height: 34,
            width: 34,
            child: FittedBox(
                child: GestureDetector(
                    onTap: () {
                      focusNode.requestFocus();
                      widget.callback();
                    },
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) {
                          isHovered = true;
                          if (focusNode.hasFocus) return;
                          change(onHoverChild);
                        },
                        onExit: (_) {
                          isHovered = false;
                          if (focusNode.hasFocus) return;
                          change(child);
                        },
                        child: visual)))));
  }
}

class _RandomButton extends GetView<AvatarEditorController> {
  const _RandomButton();

  static double _scale() =>
      Get.width >= Get.height ? 1.0 : PanelStyles.widthOnMobile / PanelStyles.width;

  @override
  Widget build(BuildContext context) => AnimatedButton(
      onTap: controller.randomize,
      decorators: [
        const AnimatedButtonScaleDecorator(max: 1.2),
        AnimatedButtonTooltipDecorator(
            tooltip: () => 'randomize_your_avatar'.tr,
            position: const GameTooltipPositionBottom(),
            scale: _scale),
        const AnimatedButtonOpacityDecorator(minOpacity: 0.6)
      ],
      child: GifManager.inst.misc('randomize').builder.init(height: 32, width: 32));
}
