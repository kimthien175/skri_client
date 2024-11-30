import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/home/home.dart';

class JiggleAvatar extends StatelessWidget {
  const JiggleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AvatarEditorController>();
    return Obx(() => Stack(
          children: [
            controller.modelRx.value.color.builder.init(),
            SlideTransition(
                position: controller.jiggleEyes.animation,
                child: controller.modelRx.value.eyes.builder.init()),
            SlideTransition(
              position: controller.jiggleMouth.animation,
              child: controller.modelRx.value.mouth.builder.init(),
            )
          ],
        ));
  }
}
