import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JiggleController extends GetxController with GetSingleTickerProviderStateMixin {
  late final animController =
      AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
  late final Animation<Offset> animation =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.06))
          .animate(CurvedAnimation(parent: animController, curve: Curves.decelerate));

  void jiggle() {
    animController.forward(from: 0).then((_) => animController.reverse());
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}

class JiggleAvatar extends StatelessWidget {
  const JiggleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AvatarEditorController>();
    return Stack(
      children: [
        // Color
        Obx(() => GifManager.inst.color(controller.color.value).builder.init()),
        // Eyes
        Obx(() => SlideTransition(
            position: controller.jiggleEyes.animation,
            child: GifManager.inst.eyes(controller.eyes.value).builder.init())),
        // Mouth
        Obx(() => SlideTransition(
            position: controller.jiggleMouth.animation,
            child: GifManager.inst.mouth(controller.mouth.value).builder.init()))
      ],
    );
  }
}
