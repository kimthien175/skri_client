import 'package:skribbl_client/pages/home/widgets/avatar_editor/controller.dart';
import 'package:skribbl_client/models/gif/gif.dart';
import 'package:skribbl_client/models/gif_manager.dart';
import 'package:skribbl_client/pages/home/widgets/avatar_editor/jiggle_avatar.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    FadeSwitcherController controller =
        Get.put(FadeSwitcherController(child), tag: hashCode.toString());
    return SizedBox(
        height: 34,
        width: 34,
        child: FittedBox(
            child: GestureDetector(
                onTap: callback,
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                      controller.change(onHoverChild);
                    },
                    onExit: (_) {
                      controller.change(child);
                    },
                    child: Obx(() => controller.child.value)))));
  }
}

class _RandomButton extends StatelessWidget {
  const _RandomButton();
  @override
  Widget build(BuildContext context) =>
      Get.find<AvatarEditorController>().randomizeBtnBuilder.build();
}

class FadeSwitcherController extends GetxController with GetSingleTickerProviderStateMixin {
  FadeSwitcherController(Widget child) {
    this.child = child.obs;
  }
  late final AnimationController animController =
      AnimationController(vsync: this, duration: duration);
  late final Animation<double> animation =
      CurvedAnimation(parent: animController, curve: Curves.linear);
  static const Duration duration = Duration(milliseconds: 100);

  late Rx<Widget> child;

  void change(Widget newChild) {
    child.value = Stack(
      children: [
        newChild,
        FadeTransition(opacity: animation, child: child.value),
      ],
    );
    animController.reverse(from: 1).then((_) {
      child.value = newChild;
    });
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}
