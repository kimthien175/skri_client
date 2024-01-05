import 'package:cd_mobile/models/avatar/avatar.dart';
import 'package:cd_mobile/models/avatar_editor/controller.dart';
import 'package:cd_mobile/models/gif/builder.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvatarEditor extends StatelessWidget {
  AvatarEditor({super.key}) {
    controller = Get.put(AvatarEditorController());
  }

  late final AvatarEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1), borderRadius: GlobalStyles.borderRadius),
        padding: const EdgeInsets.all(8),
        child: Stack(children: [
          Row(
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
              SizedBox(
                  height: 96,
                  width: 96,
                  child: FittedBox(
                      child: Obx(() => Avatar(
                            controller.color.value,
                            controller.eyes.value,
                            controller.mouth.value,
                          )))),
              Column(
                children: [
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextEyes),
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextMouth),
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextColor),
                ],
              ),
            ],
          ),
          const Positioned(right: 0, child: _RandomButton())
        ]));
  }
}

class _SwitchButton extends StatelessWidget {
  _SwitchButton(String path, String onHoverPath, this.callback) {
    child = GifManager.inst.misc(path).builder;
    onHoverChild = GifManager.inst.misc(onHoverPath).builder;
  }

  late final GifBuilder child;
  late final GifBuilder onHoverChild;
  final Function() callback;

  final controller = _SwitchButtonController();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (event) {
          controller.isHover.value = true;
        },
        onExit: (event) {
          controller.isHover.value = false;
        },
        child: GestureDetector(
            onTap: callback,
            child: SizedBox(
                height: 34,
                width: 34,
                child:
                    FittedBox(child: Obx(() => controller.isHover.value ? onHoverChild : child)))));
  }
}

class _SwitchButtonController extends GetxController {
  var isHover = false.obs;
}

class _RandomButton extends StatelessWidget {
  const _RandomButton();
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AvatarEditorController>();
    return GestureDetector(
        onTap: controller.randomize, child: GifManager.inst.misc('randomize').builder);
  }
}
