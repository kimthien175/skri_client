import 'package:cd_mobile/models/avatar/avatar.dart';
import 'package:cd_mobile/models/avatar_editor/controller.dart';
import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvatarEditor extends StatelessWidget {
  const AvatarEditor({super.key});

  static final AvatarEditorController controller = Get.put(AvatarEditorController());

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
                  _SwitchButton('left_arrow', controller.onPreviousEyes),
                  _SwitchButton('left_arrow', controller.onPreviousMouth),
                  _SwitchButton('left_arrow', controller.onPreviousColor),
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
                  _SwitchButton('right_arrow', controller.onNextEyes),
                  _SwitchButton('right_arrow', controller.onNextMouth),
                  _SwitchButton('right_arrow', controller.onNextColor),
                ],
              ),
            ],
          ),
          const Positioned(right: 0, child: _RandomButton())
        ]));
  }
}

class _SwitchButton extends StatelessWidget {
  _SwitchButton(String path, this.callback) {
    child = GifManager.inst.misc(path).widget();
  }

  late final Gif child;
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: callback, child: SizedBox(height: 34, width: 34, child: FittedBox(child: child)));
  }
}

class _RandomButton extends StatelessWidget {
  const _RandomButton();
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AvatarEditorController>();
    return GestureDetector(
        onTap: controller.randomize, child: GifManager.inst.misc('randomize').widget());
  }
}
