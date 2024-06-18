import 'package:cd_mobile/pages/home/widgets/avatar_editor/controller.dart';
import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/jiggle_avatar.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvatarEditor extends StatelessWidget {
  const AvatarEditor({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AvatarEditorController>();
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
        ),
      ),
      const Positioned(right: 3, top: 15, child: _RandomButton())
    ]);
  }
}

class _SwitchButton extends StatelessWidget {
  _SwitchButton(String path, String onHoverPath, this.callback) {
    child = GifManager.inst.misc(path).builder.init();
    onHoverChild = GifManager.inst.misc(onHoverPath).builder.init();
  }

  late final GifBuilder child;
  late final GifBuilder onHoverChild;
  final Function() callback;

  final controller = _SwitchButtonController();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
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
  _SwitchButtonController(){
    print('Switch button controller init');
  }
  var isHover = false.obs;
}

class _RandomButton extends StatelessWidget {
  const _RandomButton();
  @override
  Widget build(BuildContext context) =>
      Get.find<AvatarEditorController>().randomizeBtnBuilder.build();
}
